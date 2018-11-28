LibMultiLabel={
	_layer=nil,
}

--xml�ַ�������
--[[
<label color='0,255,0' userdata='aaaa' tag='11' class='Payment.rechargeByMessage' fontname='' fontsize='' isShadow='true'>[MyName]</label>
<image src='temp/001.png' size='123,421'/>
]]
--˵��
--label��ǩ����Ҫ���ı�����
--������:
--color 		��ɫ
--fontname 		����
--fontname 		�ֺ�
--tag  			tagֵ
--class 		��class��Ϊ��ʱ��label��ʾ����linklabel��������class�ķ���
--userdata 		��class��Ϊ��ʱ������linklable��userdata

--��ǩֵΪ�ı����ݣ�classΪ��ʱ֧��\r\n �� \n ����
--image��ǩ ��isani����Ϊ�ջ��߲�Ϊtrueʱ��src�����isaniΪtrueʱ�������ؼ����봫���ö����ķ���
--�����У�
--isani		�Ƿ��Ƕ���
--src 		ͼƬ·��
--size		��ʽ��width,height ����ͼƬ��С
--userdata

--����(*��Ϊ����)�� xml��ʽ���͵�string(*)�����(*)�����壬�ֺţ�ÿ�еļ��,��ö����ķ����������ش�userdata������

function SCALEX(x)
    return cc.Director:getInstance():getWinSize().width/480*x
end
function SCALEY(y)
    return cc.Director:getInstance():getWinSize().height /320*y
end

FONT_NAME     = "����"

FONT_DEF_SIZE = SCALEX(18)
FONT_SM_SIZE  = SCALEX(15)
FONT_BIG_SIZE = SCALEX(23)
FONT_M_BIG_SIZE = SCALEX(63)
FONT_SMM_SIZE  = SCALEX(13)
FONT_FM_SIZE=SCALEX(11)
FONT_FMM_SIZE=SCALEX(12)
FONT_FMMM_SIZE=SCALEX(9)

ccBLACK = cc.c3b(0,0,0);
ccWHITE = cc.c3b(255,255,255);
ccYELLOW = cc.c3b(255,255,0);
ccBLUE = cc.c3b(0,0,255);
ccGREEN = cc.c3b(0,255,0);
ccRED = cc.c3b(255,0,0);
ccMAGENTA = cc.c3b(255,0,255);
ccPINK = cc.c3b(228,56,214);		-- ��ɫ
ccORANGE = cc.c3b(206, 79, 2)	  -- �ٺ�ɫ
ccGRAY = cc.c3b(166,166,166);
ccC1=cc.c3b(45,245,250);
---ͨ����ɫ
ccRED1= cc.c3b(86,26,0)
ccYELLOW2=cc.c3b(241,176,63)

---
------��ȡ��Դ��·��---------------------
function P(fileName)
	if fileName then
		return ScutDataLogic.CFileHelper:getPath(fileName)
	else
		return nil
	end
end

function SX(x)
    return SCALEX(x)
end 

function SY(y)
    return SCALEY(y)
end

function LibMultiLabel:new(content,width,fontname,fontsize,nYSpace,getAniSpriteFunc,isLine)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	if fontname == nil then	
		fontname = FONT_NAME;
	end
	
	if fontsize == nil then	
		fontsize = FONT_FMM_SIZE;
	end
	
	if nYSpace == nil then --���ؼ�yλ�õļ��
		nYSpace = SY(1)
	end
	
	local layer = cc.Layer:create()
	layer:setContentSize(cc.size(width,SY(1)))  --��ʱ��С
	local xmlTable=LibXmlParser:ParseXmlText(content) --xml�ַ�������
	if #xmlTable > 0 then
		local nWidth=0 --��ǰ�еĿ��
		local nControlTable={} --������еĿؼ�
		local nLine = 1;		
		for key,value in pairs(xmlTable) do			
			--ȡ������
			local color = nil;
			local fname = nil;
			local fsize = nil;
			local userdata = nil;
			local tag = nil;
			local class = nil;			
			local src = nil;
			local size = nil;
			local text = value.Value;
			local isani=nil;
			local isShadow=false;
			for k,v in pairs(value.Attributes) do 
				k = string.lower(k)
				if k == "color" then
					color = v;					
				elseif k == "fontname" then
					fname = v;					
				elseif k == "fontsize" then
					fsize = v;					
				elseif k == "userdata" then
					userdata = v; --ZyFont.Split( v,",");
				elseif k == "tag" then
					tag = v;
				elseif k == "class" then
					class = v;				
				elseif k == "src" then
					src = v;
				elseif k == "size" then
					size = v;
				elseif k == "isani" then
					isani = string.lower(v);
				elseif k == "isshadow" then
					isShadow = string.lower(v);
				end
			
			end
			--һЩ���Դ��������õĶ���Ĭ��ֵ
			if color == nil or color == "" then
				color = ccWHITE;
			else
				color = Util.split(color,",")
				color = cc.c3b(color[1],color[2],color[3]);
			end
			if fname == nil or fname == "" then
				fname = fontname
			end
			if fsize == nil or fsize == "" then
				fsize = fontsize
			end
			
			if nControlTable[nLine] == nil then				
				nControlTable[nLine]={}
				nControlTable[nLine].height=0;
				nControlTable[nLine].items={};
			end
			
			-- local control = nil;
			if value.Name == "label" then
				if class ~= nil and class ~= "" then  --���class��ֵ��Ϊlinklabel����
					local linkLabel=LibLinkLable:new(text,color,fname,fsize,width,isLine)
					local csize=linkLabel:getContentSize();
					if csize.width + nWidth > width  then
						nLine = nLine + 1;
						nControlTable[nLine]={}
						nControlTable[nLine].height=0;
						nControlTable[nLine].items={};
						nWidth = csize.width
					else
						nWidth = nWidth + csize.width
					end
					if csize.height > nControlTable[nLine].height then
						nControlTable[nLine].height = csize.height;
					end
					table.insert(nControlTable[nLine].items,{item=linkLabel,sacelX=1,sacelY=1})
					linkLabel:registerScriptTapHandler(class);
					
					if userdata then
						linkLabel:setUserData(LibFont.Split(userdata,","))
					end					
					if tag then
						linkLabel:setTag(tag)
					end
					
					linkLabel:setPosition(PT(0,0))--����ʱ��һ��λ�� ֮������λ��
					linkLabel:addto(layer)					
				else
					--/r/n /n����	
                    if 				text then
					local textTable=LibFont.Split(string.gsub(text,"\r\n","\n"),"\n")
					for index,strText in pairs(textTable) do
						while true do
							local labelStr,str=LibFont.subString(strText,width - nWidth , fname, fsize);
							strText = str;
							if labelStr == nil or labelStr == "" then
								nLine = nLine + 1;
								nWidth = 0;
								nControlTable[nLine]={}
								nControlTable[nLine].height=0;
								nControlTable[nLine].items={};							
							else
								local label = ccui.Text:create(labelStr, fname, fsize)
								
								local csize=label:getContentSize();							
								nWidth = nWidth + csize.width							
								if csize.height > nControlTable[nLine].height then
									nControlTable[nLine].height = csize.height;
								end
								table.insert(nControlTable[nLine].items,{item=label,sacelX=1,sacelY=1})
								if tag then
									label:setTag(tag)
								end
								if(isShadow=='true') then
								   label:enableShadow()
								end
								label:setColor(color);
								label:setAnchorPoint(cc.p(0,0))
								label:setPosition(cc.p(0,0))--����ʱ��һ��λ�� ֮������λ��
								layer:addChild(label,0)	
								
								
							end	
							if strText == nil or strText == "" then
								break;
							end
						end
						if index<#textTable then
							nLine = nLine + 1;
							nWidth = 0;
							nControlTable[nLine]={}
							nControlTable[nLine].height=0;
							nControlTable[nLine].items={};
						end
					end
				end
				end
			elseif value.Name == "image" then
				local img=nil
				if isani == "true" then
					img = getAniSpriteFunc(userdata);
				else
					img = cc.Sprite:create(P(src));
				end
				local scalex=1
				local scaley=1
				if size then
					size=LibFont.Split(size,",")
					scalex=tonumber(size[1])/img:getContentSize().width
					scaley=tonumber(size[2])/img:getContentSize().height
					img:setScaleX(scalex)
					img:setScaleY(scaley)
				end
				
				local csize=img:getContentSize();
				if csize.width*scalex + nWidth > width  then
					nLine = nLine + 1;
					nControlTable[nLine]={}
					nControlTable[nLine].height=0;
					nControlTable[nLine].items={};
					nWidth = csize.width*scalex
				else
					nWidth = nWidth + csize.width*scalex
				end
				if csize.height*scaley > nControlTable[nLine].height then
					nControlTable[nLine].height = csize.height*scaley;
				end
				if tag then
					img:setTag(tag)
				end
				table.insert(nControlTable[nLine].items,{item=img,sacelX=scalex,sacelY=scaley})
				img:setAnchorPoint(PT(0,0))
				img:setPosition(PT(0,0))--����ʱ��һ��λ�� ֮������λ��
				layer:addChild(img,0)	
			end			
		end	
		--�ȱ���һ�μ���layer�߶�
		local layerHeight=0
		for key,value in pairs(nControlTable) do
			layerHeight = value.height + layerHeight
		end
		layerHeight = layerHeight + (#nControlTable-1)*nYSpace;
		local layerWidth=width
		if #nControlTable==1 then
			layerWidth=nWidth
		end
		layer:setContentSize(cc.size(layerWidth,layerHeight))
		--�������пؼ�����position
		local offy = layerHeight;
		for key,value in pairs(nControlTable) do
			local offx=0
			offy = offy - value.height/2;
			for k,v in pairs (value.items) do
				v.item:setPosition(cc.p(offx,offy-v.item:getContentSize().height*v.sacelY/2))
				offx = offx + v.item:getContentSize().width*v.sacelX;
			end			
			offy = offy - value.height/2 - nYSpace;
		end
	end	
	
	instance._layer = layer
	return instance
end
--����λ��
function LibMultiLabel:setPosition(point)
	self._layer:setPosition(point)
end

function LibMultiLabel:getPosition(point)
	return self._layer:getPosition()
end
function LibMultiLabel:setAnchorPoint(point)
	self._layer:setAnchorPoint(point)
end
function LibMultiLabel:addto(parent, param1, param2)
	if type(param1) == "userdata" then
		parent:addChildItem(self._layer, param1)
	else
		if param2 then
			parent:addChild(self._layer, param1, param2)
		elseif param1 then
			parent:addChild(self._layer, param1)
		else
			parent:addChild(self._layer, 0)
		end
	end
end
--�����Ƿ�����
function LibMultiLabel:setIsVisible(visible)
	self._layer:setIsVisible(visible)
end
--����Ƿ�����
function LibMultiLabel:getIsVisible()
	return self._layer:getIsVisible()
end

function LibMultiLabel:getLayer()
	return self._layer
end

function LibMultiLabel:getContentSize()
	return self._layer:getContentSize()
end

function LibMultiLabel:setContentSize(size)
	self._layer:setContentSize()
end

function LibMultiLabel:addChild(child ,zorder)
	if zorder ~= nil then
		self._layer:addChild(child, zorder);
    else
		self._layer:addChild(child, 0);
    end
end

function LibMultiLabel:setTag(tag)
	self._layer:setTag(tag)
end

function  LibMultiLabel:removeLabel()
	self._layer:getParent():removeChild(self._layer,true)
end;

function LibMultiLabel:getTag()
	return self._layer:getTag()
end