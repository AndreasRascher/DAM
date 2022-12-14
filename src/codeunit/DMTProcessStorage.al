/// <summary>
/// <p>Use as an Single Instance alternative if you need to clear the single instance values on error.</p>
/// <p>* <b>Concept:</b></p>
///   <p> 2 Instances of the same codeunit are alive after calling the first publisher.</p>
///   <p> Events are used to exchange values between these instances.</p>
/// <p>* <b>Usage</b>: Before the process starts call <i>Set(ValueToStore)</i> to activate the binding and set the value.</p>
/// <p>The process called after should be runmodal or if codeunit.run(). If not the variable will quickly run out of scope before <i>Get()</i> is called.</p>
/// <p>As long as the codeunit is in scope (alive) every other object can access the stored value by calling <i>Get()</i></p>
/// </summary>

/*
Code   | ProcessStorage Instanz 1 | Call Publisher Set                    | Call Publisher Get
-------|--------------------------|------------------- -------------------|--------------------
Global |			              | Subcriber -> ProcessStorage Instanz 2 | Subscriber -> ProcessStorage Instanz 2
       |                          | Store Global                          | Get Global
*/
codeunit 110016 "DMTProcessStorage"
{
    EventSubscriberInstance = Manual;

    procedure Set(Storage: Variant)
    begin
        // Redo binding fixes problem with 2nd call 
        if IsBindingActive() then
            Unbind();
        Bind();
        SetPublisher(Storage);
    end;

    procedure Get(var Storage: Variant)
    begin
        ErrorIfBindingIsNotActive();
        GetPublisher(Storage);
    end;

    procedure Get() Storage: Variant;
    begin
        ErrorIfBindingIsNotActive();
        GetPublisher(Storage);
    end;

    local procedure Bind()
    begin
        BindSubscription(GlobalProcessStorage);
    end;

    procedure Unbind()
    begin
        UnbindSubscription(GlobalProcessStorage);
    end;

    local procedure ErrorIfBindingIsNotActive()
    begin
        if not IsBindingActive() then
            Error('Bindsubscribtion has to be used for the DMTProcessStorage Codeunit');
    end;

    local procedure IsBindingActive(): Boolean
    var
        EventSubscription: Record "Event Subscription";
    begin
        EventSubscription.SetRange(EventSubscription."Publisher Object ID", Codeunit::DMTProcessStorage);
        EventSubscription.FindFirst();
        exit(EventSubscription.Active);
    end;

    #region  SettingDataEvents
    [BusinessEvent(false)]
    local procedure SetPublisher(var Storage: Variant)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"DMTProcessStorage", 'SetPublisher', '', false, false)]
    local procedure SetStorage(var Storage: Variant)
    begin
        GlobalStorageVariant := Storage;
    end;
    #endregion  SettingDataEvents

    #region  GettingDataEvents
    [BusinessEvent(false)]
    local procedure GetPublisher(var Storage: Variant)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"DMTProcessStorage", 'GetPublisher', '', false, false)]
    local procedure GetStorage(var Storage: Variant)
    begin
        Storage := GlobalStorageVariant;
    end;
    #endregion  GettingDataEvents

    var
        GlobalProcessStorage: Codeunit DMTProcessStorage;
        GlobalStorageVariant: Variant;

}