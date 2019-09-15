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

-- global illumination (0-8)
gi=10

lastTime=0
shades={}

function loadShades()
	for color=0,15 do
		shades[color]={}

		local shadeSpr=0
		if color<8 then shadeSpr=0 else shadeSpr=16 end
		local sprAddr=0x4000+32*shadeSpr

		for amount=0,7 do		
			local shade=peek4(sprAddr*2+amount+color%8*8)
			shades[color][amount]=shade
		end
	end
end

function init()
	loadShades()
end

init()
function TIC()
	if btn(0) then ly=ly-2 end
	if btn(1) then ly=ly+2 end
	if btn(2) then lx=lx-2 end
	if btn(3) then lx=lx+2 end

	if btn(4) then lr=lr+1 end
	if btn(5) then lr=lr-1 end

	cls(13)
	spr(1+t%60//30*2,x,y,14,3,0,0,2,2)
	print("HELLO WORLD!",84,84)
	t=t+1

	local now=time()
	local fps=1000/(now-lastTime)
	print("FPS:"..math.floor(fps),0,0,6)
	lastTime=now
end

function sqrDist( x1, y1, x2, y2 )
	return (x2-x1)^2 + (y2-y1)^2
end


function SCN(scnline)
	for i=0,238,2 do
		local r1=1/sqrDist(lx,ly,i,scnline)
		local shadeAmount1= (lr - r1*lf) // 1
		shadeAmount1=math.min(shadeAmount1,7)
		shadeAmount1=math.max(shadeAmount1,0)

		local r2=1/sqrDist(lx,ly,i+1,scnline)
		local shadeAmount2= (lr - r2*lf) // 1
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

