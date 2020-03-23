-- title:  helloLight
-- author: lincerely
-- desc:   playing with fire
-- script: lua

t=0
x=96
y=24

lx=120
ly=68
lf=4628
lr=10
ls=1

-- global illumination (0-8)
gi=0

lastTime=0
shades={}

function loadShades()
	for color=0,15 do
		shades[color]={}

		local shadeSpr=0
		if color<8 then shadeSpr=6 else shadeSpr=22 end
		local sprAddr=0x4000+32*shadeSpr

		for amount=0,7 do		
			local shade=peek4(sprAddr*2+amount+color%8*8)
			shades[color][amount]=shade
		end
	end
end

function init()
	loadShades()
	local w,h= 160,144
	clip((240-w)/2,0,w,h)
end

init()
function TIC()
	if btn(0) then y=y-2 end
	if btn(1) then y=y+2 end
	if btn(2) then x=x-2 end
	if btn(3) then x=x+2 end

	if btn(4) then gi=gi+1 end
	if btn(5) and gi>1 then gi=gi-1 end

	cls(0)
	spr(1+t%60//30*2,x,y,14,3,0,0,2,2)
	print("HELLO WORLD!",84,70)
	t=t+1

	local now=time()
	local fps=1000/(now-lastTime)
	print("FPS:"..math.floor(fps),90,100,6)
	lastTime=now

	ly = y + 20
	lx = x + 50
	lr = 8 + math.random(1)

	drawShadow()
	drawWater()
end

function sqrDist( x1, y1, x2, y2 )
	return (x2-x1)^2 + (y2-y1)^2
end

waterY = 20
function drawWater()
	local addrW = (136 - waterY) * 120 
	local addrR = (136 - waterY - 1) * 120
	for yOffset=1,waterY do
		-- -1, 0, 1, 0, -1, 0, 1
		memcpy(addrW, addrR + (yOffset+t//10)%2 - 1, 120)
		addrW=addrW+120
		addrR=addrR-120
	end
end

function SCN(scnline)
end

function drawShadow()
	for scnline=0,136 do
		if scnline > 136 - waterY then return end

		for i=0,238,2 do
			lf = 4478 + math.random(100)
			local r1=1/sqrDist(lx,ly,i,scnline) * ls
			local shadeAmount1= (lr - r1*lf) // 1
			shadeAmount1=shadeAmount1-gi
			shadeAmount1=math.min(shadeAmount1,7)
			shadeAmount1=math.max(shadeAmount1,0)

			local r2=1/sqrDist(lx,ly,i+1,scnline) * ls
			local shadeAmount2= (lr - r2*lf) // 1
			shadeAmount2=shadeAmount2-gi
			shadeAmount2=math.min(shadeAmount2,7)
			shadeAmount2=math.max(shadeAmount2,0)

			if shadeAmount1~=0 or shadeAmount2~=0 then
				local orgColors=peek(scnline*120+i/2)

				local color1=orgColors&15
				local color2=(orgColors>>4)&15

				local shade1=shades[color1][shadeAmount1] 
				local shade2=shades[color2][shadeAmount2] 

				local finalColors=shade2<<4 | shade1
				poke(scnline*120+i/2,finalColors)
			end
		end
	end
end

