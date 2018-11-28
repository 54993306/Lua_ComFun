
function __G__TRACKBACK__(errorMessage)
    if device.platform == "android" then
	    buglyReportLuaException(tostring(errorMessage), debug.traceback())
	end
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
    -- if device.platform == "windows" or device.platform == "mac" or device.platform == "android" then
    --     --if true then
    --     device.showAlert("LUA ERROR", tostring(errorMessage)..debug.traceback("", 2), "OK")
    -- end
--      Toast.getInstance():show("LUA ERROR:"..errorMessage)
end

release_print(string.format("%s", package.path));
package.path = "src/";
cc.FileUtils:getInstance():setPopupNotify(false);
MyAppInstance = require("app.MyApp").new();
MyAppInstance:run();
