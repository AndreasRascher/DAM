codeunit 73009 DMTNotifications
{
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Page, Page::DMTDocMigrations, 'OnOpenPageEvent', '', true, true)]
    local procedure Page_DMTDocMigrations_OnOpenPageEvent()
    begin
        SchemaFileDataIsMissing_SendNotification();
    end;

    procedure SchemaFileDataIsMissing_SendNotification()
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        DMTSetup: Record DMTSetup;
        NewNotification: Notification;
        NotificationMsg: Label 'No schema data found, open setup and import schema.csv file.';
        OpenLabelMsg: Label 'Open %1';
    begin
        if not DMTFieldBuffer.IsEmpty then
            exit;
        NewNotification.Message := NotificationMsg;
        NewNotification.Scope := NotificationScope::LocalScope;
        NewNotification.AddAction(StrSubstNo(OpenLabelMsg, DMTSetup.TableCaption), Codeunit::DMTNotifications, 'SchemaFileDataIsMissing_ProcessNotification');
        NewNotification.Send();
    end;

    procedure SchemaFileDataIsMissing_ProcessNotification(SchemaFileDataIsMissing: Notification)
    begin
        Page.Run(Page::"DMT Setup");
    end;

    procedure NotifyIfSetupFolderPathIsDifferentForExistingDataFiles()
    begin

    end;

    //     LOCAL NotificationTest()
    // MyNotification.MESSAGE := 'This is a notification';
    // MyNotification.SCOPE := NOTIFICATIONSCOPE::LocalScope;
    // MyNotification.SETDATA('Position',GLBudgetName.GETPOSITION);
    // MyNotification.ADDACTION(STRSUBSTNO('Fibu-Budget %1 öffnen',GLBudgetName.Name),CODEUNIT::ActionHandler,'OpenGLBudget');
    // MyNotification.SEND;
}