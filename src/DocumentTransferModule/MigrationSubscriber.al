codeunit 110021 DMTDocMigrSubscriber
{
    EventSubscriberInstance = Manual;

    procedure Bind()
    begin
        BindSubscription(GlobalMigrationSubscriber);
    end;

    procedure Unbind()
    begin
        UnbindSubscription(GlobalMigrationSubscriber);
    end;
    // Hide dialog when validating customer name fields in sales header
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeShouldSearchForCustomerByName', '', true, true)]
    local procedure SalesHeader_OnBeforeShouldSearchForCustomerByName(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    var
        GlobalMigrationSubscriber: Codeunit DMTDocMigrSubscriber;
}