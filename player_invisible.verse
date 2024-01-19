
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Fortnite.com/Characters }

player_invisible := class(creative_device):

    @editable
    TurnInvisible : button_device = button_device{}

    @editable
    TurnVisible : button_device = button_device{}

    InvButtonText<localizes> : message = "Hide Player and HUD"
    var PlayerCanvas : canvas = canvas{}

    HideAction(Message : widget_message) : void=
        # This function hides the character and removed the 
        # HUD from the player's canvas

        Player := Message.Player

        if (Agent := agent[Player], FC := Agent.GetFortCharacter[]):
            if (PlayerUI := GetPlayerUI[Player]):
                PlayerUI.RemoveWidget(PlayerCanvas)
                FC.Hide()


    CreateUI() : canvas=

        # To get yellow button on screen
        CanvasButton : button_loud = button_loud{DefaultText := InvButtonText}
        CanvasButton.OnClick().Subscribe(HideAction)

        # positioning of the UI on the player's screen (center)
        NewCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := CanvasButton


    HandleInvButtonPressed(Agent : agent) : void= 
        # Adds UI to the player's screen and prompts for invisibility

        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):

            # initializing the UI based on config details laid out by the CreateUI() fn
            set PlayerCanvas = CreateUI()

            # attaching the widget to player with UI input mode enabled
            PlayerUI.AddWidget(PlayerCanvas, player_ui_slot{InputMode := ui_input_mode.All})


    # Including this function to be able to move to challenge 2 found on the same level
    HandleVisButPressed(Agent : agent) : void= 
        if (FC := Agent.GetFortCharacter[]):
            FC.Show()


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        
        # If this button is pressed, add a UI to the player's screen 
        TurnInvisible.InteractedWithEvent.Subscribe(HandleInvButtonPressed)

        # If player is invisible, then pressing this button will flip visibility
        TurnVisible.InteractedWithEvent.Subscribe(HandleVisButPressed)

    