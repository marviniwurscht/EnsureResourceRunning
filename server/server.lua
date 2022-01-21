ESX = nil

--Initial
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Creating the secret
Citizen.CreateThread(function()
	local restartCount = 0

	while true do
		Citizen.Wait(2000)
		
		--Check if the resource is missing
		if GetResourceState(Config.ResourceName) ~= "missing" 
			and GetResourceState(Config.ResourceName) ~= "unknown" then
			
			-- While the resource status is chaning: wait
			while GetResourceState(Config.ResourceName) == "starting"
				or GetResourceState(Config.ResourceName) == "uninitialized"
				or GetResourceState(Config.ResourceName) == "stopping" do

				Citizen.Wait(100)
			end
			
			-- If the resource is started check for function
			if GetResourceState(Config.ResourceName) == "started" then
				local try = pcall(testResource)
				
				if try then 
					--Success (Anticheat running)
					printInfo("Anticheat started Successfully")
					break
				else
					--Anticheat is started but not functioning corretly: restarting it
					printInfo("Resource has been started but is not working correctly. Stopping Resource...")
					StopResource(Config.ResourceName)
					Citizen.Wait(3000)
				end
			
			-- If the resource is stopped start it
			elseif GetResourceState(Config.ResourceName) == "stopped" then
				if restartCount < Config.MaximumRestartTries then
					restartCount = restartCount + 1
					printInfo("Resource was stopped. Starting Resource...")
					StartResource(Config.ResourceName)
					Citizen.Wait(3000)
				else
					StartResource(Config.ResourceName)
					printInfo("Resource was stopped. Starting Resource...")
					printInfo("Restart limit of ".. Config.MaximumRestartTries .." reached. Exiting...")
					break
				end
			end
			
		else
			--Resource is missig
			printInfo("IMPORTANT: RESOURCE " .. Config.ResourceName .. " MISSING OR UNKNOWN!")
		end
	end
end)

function testResource()
	exports[Config.ResourceName]:getAllPlayerIdentifiers(-1, false)
end