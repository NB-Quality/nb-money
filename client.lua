local initialed = false 
local hideAt = nil

ShowNotificationTicker = function(label,...)
    logInPauseMenu = 1
    BeginTextCommandThefeedPost(label)
    local opts = {...}
    for i,v in pairs(opts) do 
        AddTextComponentSubstringPlayerName(v or "")
    end 
    EndTextCommandThefeedPostTicker(0,logInPauseMenu)
end
ShowNotificationTicker2 = function(msg)
    logInPauseMenu = 1
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg or "")
    EndTextCommandThefeedPostTicker(0,logInPauseMenu)
end

local ShowNotificationLabel = ShowNotificationTicker
local ShowNotification = ShowNotificationTicker2


UpdatePlayerMpMoneyUI = function (cash,bank)
    StatSetInt(`MP0_WALLET_BALANCE`, cash, true)
    StatSetInt(`BANK_BALANCE`, bank, true)
    if not config.displayMPMoney then goto theend end 
    DisplayCash(true) 
    UseFakeMpCash(true);
    SetMultiplayerWalletCash();
    SetMultiplayerBankCash();
    UseFakeMpCash(false);
    hideAt = GetGameTimer() + config.fadeoutTimerMS
    
    ::theend::
    if not initialed then initialed = true end 
end

RegisterNetEvent(GetCurrentResourceName()..":UpdateClient",function(msg,islabel,...)
    if islabel then ShowNotificationLabel(msg,...) 
    else ShowNotification(msg) end
    TriggerServerCallback("GetPlayerMoney",function(money_account)
        UpdatePlayerMpMoneyUI(money_account.cash,money_account.bank)
    end,"cash","bank")
end)

RegisterNetEvent(GetCurrentResourceName()..":FailedClientMessage",function(msg,islabel,...)
    print(123)
    if islabel then ShowNotificationLabel(msg,...) 
    else ShowNotification(msg) end 
end)

CreateThread(function()
	while true do
		Wait(0)
		if not initialed and NetworkIsSessionStarted() then
			TriggerServerCallback("GetPlayerMoney",function(money_account)
                UpdatePlayerMpMoneyUI(money_account.cash,money_account.bank)
            end,"cash","bank")
			return
		end
	end
end)

if not ( config.fadeoutTimerMS == 0 ) then 
    CreateThread(function()
        while true do 
            Wait(500)
            if hideAt and GetGameTimer() > hideAt then 
                RemoveMultiplayerWalletCash();
                RemoveMultiplayerBankCash();
                DisplayCash(false) 
                hideAt = nil
            end 
        end 
    end) 
end 

ChargerMoney = function(type,amount,cb,reason)
    while not initialed do Wait(0) end  
    TriggerServerCallback("ChargerMoney",function(success)
        if success then 
            TriggerServerCallback("GetPlayerMoney",function(money_account)
                UpdatePlayerMpMoneyUI(money_account.cash,money_account.bank)
                --print(json.encode(money_account))
            end,"cash","bank")
        end 
        if cb then cb(success) end 
    end,amount,type,reason)
end

exports("ChargerMoney",ChargerMoney)
if not config.disableEvents then 
    AddEventHandler("ChargerMoney",ChargerMoney)
end 

receiveSalary = function(amount)
    BeginTextCommandThefeedPost("GOODBOYTICK")
    AddTextComponentInteger(amount, true)
    EndTextCommandThefeedPostTicker(false, true)
    BeginTextCommandThefeedPost("GOODBOYRMDR")
    EndTextCommandThefeedPostTicker(false, true)
end
RegisterNetEvent("receiveSalary",receiveSalary) 