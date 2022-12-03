/// <summary>
/// <p>Use as an Single Instance alternative if you need to clear the single instance values on error.</p>
/// <p>Concept:</p>
///   <p>- 2 Instances of the same codeunit are alive after calling the first publisher</p>
///   <p>- Events are used to exchange values between these instances</p>
/// <p>Usage: Before the process starts call Set(ValueToStore) to active the binding and set the value.</p>
/// <p>The process called after should be runmodal or if codeunit.run(). If not the variable will quickly run out of scope before get() is called.</p>
/// <p>As long as the codeunit is in scope (alive) every other object can access the stored value by calling Get()</p>
/// </summary>
codeunit 110016 "DMTProcessStorage"
{
    EventSubscriberInstance = Manual;

    procedure Set(Storage: Variant)
    begin
        if not IsBindingActive() then
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

    [BusinessEvent(false)]
    local procedure SetPublisher(var Storage: Variant)
    begin
    end;

    [BusinessEvent(false)]
    local procedure GetPublisher(var Storage: Variant)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"DMTProcessStorage", 'SetPublisher', '', false, false)]
    local procedure SetStorage(var Storage: Variant)
    begin
        GlobalStorageVariant := Storage;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"DMTProcessStorage", 'GetPublisher', '', false, false)]
    local procedure GetStorage(var Storage: Variant)
    begin
        Storage := GlobalStorageVariant;
    end;

    var
        GlobalProcessStorage: Codeunit DMTProcessStorage;
        GlobalStorageVariant: Variant;

}