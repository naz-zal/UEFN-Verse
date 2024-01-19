
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Playspaces }

# declaring the gameplay tags here
CoinCollectibleTag := class(tag){}
TeleporterDeviceTag := class(tag){}

# A Verse-authored creative device that can be placed in a level
collectible_to_teleporter := class(creative_device):

    @editable
    var Teleporter_one : teleporter_device = teleporter_device{}

    @editable
    var PlayerCounter : player_counter_device = player_counter_device{}

    var PlayerDataMap : [player]PlayerData = map{}
    var TeleporterArray: []teleporter_device = array{}

    OnPlayerAdded(InPlayer : player) : void=
        # method called when a new player joins a session in progress. 

        Print("A new player joined!")

        Data := PlayerData{}     

        if (set PlayerDataMap[InPlayer] = Data):
            if (set PlayerDataMap[InPlayer].Teleporter = TeleporterArray[0]):
                Print("Teleporter device assigned to player")
                if (temp := TeleporterArray.RemoveElement[0]):
                    set TeleporterArray = temp
                    # for debugging
                    Print("The length of the array is now {TeleporterArray.Length}")


    RestoreTeleporter(Agent : agent): void=
        # method called when a player leaves the session 
        # and their teleporter is added back to the teleporter array

        if (Player := player[Agent]):
            if ( playerTeleporter := PlayerDataMap[Player].Teleporter):
                set TeleporterArray += array{playerTeleporter}

    OnCoinCollected(Agent: agent): void=

        # for debugging
        Print("Collected the coin!")

        # increment player coins collected count and teleport player back
        if (Player := player[Agent]):
            if (PlayerObj := PlayerDataMap[Player]):
                set PlayerObj.CoinsCollected += 1
                PlayerObj.Teleporter.Teleport(Player)
                Print("Coins collected: {PlayerObj.CoinsCollected}")
                
        # once coin is collected, respawn the coin for all players        
        CoinCollectibles := GetCreativeObjectsWithTag(CoinCollectibleTag{})

        for (CoinItems : CoinCollectibles, CoinItem := collectible_object_device[CoinItems]):
            CoinItem.RespawnForAll()


    AssignTeleporter(): void=

        AllPlayers := GetPlayspace().GetPlayers()
        
        # returns list of teleporters with "TeleporterDeviceTag" and 
        # list of collectibles with "CoinCollectibleTag" tag

        Teleporter_list := GetCreativeObjectsWithTag(TeleporterDeviceTag{})

        # append all teleporters to empty array at the start of the game
        for (Teleporter: Teleporter_list, TeleporterDevice := teleporter_device[Teleporter]):
            set TeleporterArray += array{TeleporterDevice}

        for (Agent : AllPlayers, user := player[Agent]):
            # initializing an instance of PlayerData class
            Data := PlayerData{}     

            if (set PlayerDataMap[user] = Data):
                if (set PlayerDataMap[user].Teleporter = TeleporterArray[0]):
                    Print("Teleporter device assigned to player")
                    if (temp := TeleporterArray.RemoveElement[0]):
                        set TeleporterArray = temp
                        # for debugging
                        Print("The length of the array is now {TeleporterArray.Length}")


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        CoinCollectibles := GetCreativeObjectsWithTag(CoinCollectibleTag{})
        for (CoinItems : CoinCollectibles, CoinItem := collectible_object_device[CoinItems]):
            CoinItem.CollectedEvent.Subscribe(OnCoinCollected)

        PlayerCounter.RemovedEvent.Subscribe(RestoreTeleporter)
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)

        AssignTeleporter()

