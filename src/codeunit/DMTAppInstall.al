codeunit 73000 "DMT App Install"
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
        HandleReInstall();
    end;

    local procedure HandleFreshInstall();
    begin
        if not CheckIfThisIsFirstInstallOfApp() then
            exit;
    end;

    local procedure HandleReInstall();
    begin
        if CheckIfThisIsFirstInstallOfApp() then
            exit;
    end;

    local procedure CheckIfThisIsFirstInstallOfApp(): Boolean
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() = Version.Create(0, 0, 0, 0));
    end;
}