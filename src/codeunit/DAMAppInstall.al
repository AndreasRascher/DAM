codeunit 91009 "DAM App Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        // HandleFreshInstall();
        // HandleReinstall();
    end;

    trigger OnInstallAppPerDatabase()
    begin
        HandleFreshInstall();
        HandleReinstall();
    end;

    local procedure HandleFreshInstall();
    begin
        if Not CheckIfThisIsFirstInstallOfApp() then
            exit;
        PopulateAppWithDefaultData();
    end;

    local procedure HandleReInstall();
    begin
        if CheckIfThisIsFirstInstallOfApp() then
            exit;
        PopulateAppWithDefaultData();
    end;

    local procedure CheckIfThisIsFirstInstallOfApp(): Boolean
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() = Version.Create(0, 0, 0, 0));
    end;

    local procedure PopulateAppWithDefaultData()
    var
        DAMExportObject: Record DAMExportObject;
    begin
        DAMExportObject.DeleteAll();
        NavApp.LoadPackageData(Database::DAMExportObject);
    end;
}