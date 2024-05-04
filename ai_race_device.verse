using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

using { /Fortnite.com/Game }
 
 
# Visit [here](https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse) to create a verse device.
 
 
# A Verse-authored creative device that can be placed in a level
npc_spawner_device_example := class(npc_behavior):

    UpdateRateSeconds<private>:float = 0.1

    @editable
    DistanceFromSpawnPtToMove:float = 1500.0
 
 
    # Reference to the NPC Spawner Device in the level.
    # In the Details panel for this Verse device,
    # set this property to your NPC Spawner Device.
    @editable
    MyNPCSpawnerDevice:npc_spawner_device = npc_spawner_device{}

    @editable
    MyNPCSpawnerDeviceTwo:npc_spawner_device = npc_spawner_device{}

    @editable
    Mutant : mutator_zone_device = mutator_zone_device{}
 
 
    # Runs when the device is started in a running game.
    OnBegin<override>()<suspends>:void=

        if:
            Agent := GetAgent[]
            FortCharacter := Agent.GetFortCharacter[]
        then:
            spawn { DeviceFollowCharacter() }
            # Subscribe the character's damaged event to OnDamaged
            FortCharacter.DamagedEvent().Subscribe(OnDamaged)
            Mutant.AgentEntersEvent.Subscribe(OnPlayerEnteredMutZone)
    
    DeviceFollowCharacter()<suspends>:void=
        if:
            # Get the agent (AI Character) this behavior is associated with.
            Agent := GetAgent[]
    
            # Get the fort_character interface of the agent to access Fortnite character-specific behaviors, events, functions, and interfaces.
            Character := Agent.GetFortCharacter[]
        then:
            # Loop MoveTo on the HealVolume and VFXSpawner to match their position to the
            # NPC Character
            loop:
                CharacterTransform := Character.GetTransform()
                Mutant.MoveTo(CharacterTransform.Translation, CharacterTransform.Rotation, UpdateRateSeconds)
                Sleep(UpdateRateSeconds)
            
    OnPlayerEnteredMutZone( PlayerThatEntered : agent ):void=

        if:
            # Get the Agent and the Navigatable interface
            Agent := GetAgent[]

            Character := Agent.GetFortCharacter[]
            Navigatable := Character.GetNavigatable[]

        then:
            NavigationTarget := MakeNavigationTarget(PlayerThatEntered)
            spawn{Navigatable.NavigateTo(NavigationTarget)}

    # When the NPC is damaged, start chasing the character
    # that instigated the damage
    OnDamaged(DamageResult:damage_result):void=
        Print("I've been damaged!!")
        MaybeInstigator := DamageResult.Instigator
        if:
            # Get the Agent and the Navigatable interface
            Agent := GetAgent[]

            Character := Agent.GetFortCharacter[]
            Navigatable := Character.GetNavigatable[]

            Instigator := MaybeInstigator?
            InstigatingAgent := Instigator.GetInstigatorAgent[]

        
        # if (Instigator := MaybeInstigator?):
        #     if (InstigatingAgent := Instigator.GetInstigatorAgent[]):
        #         NavigationTarget := MakeNavigationTarget(InstigatingAgent)
        #         spawn{Navigatable.NavigateTo(NavigationTarget)}

        then:
            # Start navigating to the InstigatingAgent
            Print("Helloooo")
            NavigationTarget := MakeNavigationTarget(InstigatingAgent)
            spawn{Navigatable.NavigateTo(NavigationTarget)}
 
    