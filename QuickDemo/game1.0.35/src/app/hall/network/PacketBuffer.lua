require("app.hall.network.ByteStringAnalyze");
cc.utils1 = require("app.framework.cc.utils.init");

PacketBuffer = class("PacketBuffer");

PacketBuffer.ENDIAN = cc.utils1.ByteArrayVarint.ENDIAN_BIG
PacketBuffer.PACKET_MAX_LEN = 655360

PacketBuffer.CONTENT_LEN = 4	-- length of content body
PacketBuffer.CODE_LEN = 4	-- length of message type
PacketBuffer.SUBCODE_LEN = 4	-- length of message code
PacketBuffer.HEAD_LEN = 12	-- length of total head

function PacketBuffer.getBaseBA()
	return cc.utils1.ByteArray.new(PacketBuffer.ENDIAN)
end

function PacketBuffer.createMessage(code, subcode, dataString)
    local buf = PacketBuffer.getBaseBA();
    local content_len = (dataString == nil) and 0 or string.len(dataString);
    buf:writeInt(code);
    buf:writeInt(subcode);
    buf:writeInt(content_len);

    if dataString then
        buf:writeString(dataString);
    end
    return buf;
end

function PacketBuffer:ctor()
	self:init()
end

function PacketBuffer:init()
    self.buf=ByteStringAnalyze.new()
end

function PacketBuffer:parseMessage(__byteString)
    local msgs = {}
    self.buf:writeBuf(__byteString);
    local __preLen = PacketBuffer.HEAD_LEN
    --printf("analyzing... buffer len: %u, Pos:%u, available: %u", self.buf:getLen(),self.buf:getPos(), self.buf:getAvailable());
    while self.buf:getAvailable() >= __preLen do
        local code = self.buf:readInt();
        local subcode = self.buf:readInt();
        local bodyLen = self.buf:readInt();
        --print(" The bodyLen is ", bodyLen);

        -- buffer is not enougth, waiting...
        if self.buf:getAvailable() < bodyLen then 
            printf("received data is not enough, waiting... need %u, get %u", bodyLen, self.buf:getAvailable())
            self.buf:setPos(self.buf:getPos() - PacketBuffer.HEAD_LEN);
            break
        end
        
        if bodyLen <= PacketBuffer.PACKET_MAX_LEN then
            local content = nil
            if bodyLen > 0 then
                content = self.buf:readBuf(bodyLen);
                if code > 0 then
                    Log.i("------parseMessage subcode", subcode);
                    Log.i("------parseMessage content", content);
                    Log.s("------parseMessage subcode", subcode)
                    Log.s("------parseMessage content", content)                    
                end 
            end

            local msg = {}
            msg.code = code;
            msg.subcode = subcode;
            msg.content = content;
            msgs[#msgs + 1] = msg;
            --printf("after get body position:%u available size :%u", self.buf:getPos(), self.buf:getAvailable());
        end
    end
    -- clear buffer on exhausted
    if self.buf:getAvailable() <= 0 then
        self:init();
    end
    return msgs
end
