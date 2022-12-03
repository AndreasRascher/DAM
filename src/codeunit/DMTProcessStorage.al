codeunit 110016 "DMTProcessStorage"
{
    EventSubscriberInstance = Manual;

    procedure Set(var ProcessingPlan: Record DMTProcessingPlan)
    begin
        CheckIfBindingActive();
        SetPublisher(ProcessingPlan);
    end;

    procedure Get(var ProcessingPlan: Record DMTProcessingPlan)
    begin
        GetPublisher(ProcessingPlan);
    end;

    procedure Bind()
    begin
        BindSubscription(GlobalProcessStorage);
    end;

    procedure Unbind()
    begin
        UnbindSubscription(GlobalProcessStorage);
    end;

    local procedure CheckIfBindingActive()
    var
        EventSubscription: Record "Event Subscription";
    begin
        EventSubscription.SetRange(EventSubscription."Publisher Object ID", Codeunit::DMTProcessStorage);
        EventSubscription.FindFirst();
        if not EventSubscription.Active then
            Error('Bindsubscribtion has to be used for the DMTProcessStorage Codeunit');
    end;

    [BusinessEvent(false)]
    local procedure SetPublisher(var ProcessingPlan: Record DMTProcessingPlan)
    begin
    end;

    [BusinessEvent(false)]
    local procedure GetPublisher(var ProcessingPlan: Record DMTProcessingPlan)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"DMTProcessStorage", 'SetPublisher', '', false, false)]
    local procedure SetStorage(var ProcessingPlan: Record DMTProcessingPlan)
    begin
        GlobalProcessingPlan.Copy(ProcessingPlan);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"DMTProcessStorage", 'GetPublisher', '', false, false)]
    local procedure GetStorage(var ProcessingPlan: Record DMTProcessingPlan)
    begin
        ProcessingPlan.Copy(GlobalProcessingPlan);
    end;

    var
        GlobalProcessingPlan: Record DMTProcessingPlan;
        GlobalProcessStorage: Codeunit DMTProcessStorage;


}