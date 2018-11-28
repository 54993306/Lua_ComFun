--兑换网络
ExchangeSocketProcesser = class("ExchangeSocketProcesser", SocketProcesser)

function ExchangeSocketProcesser:exchangeResult(cmd, packetInfo)
    info = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, info);
end

ExchangeSocketProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_EXCHANGE_CODE]   = ExchangeSocketProcesser.exchangeResult;
};
