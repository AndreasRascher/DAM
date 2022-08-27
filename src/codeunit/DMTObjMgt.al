codeunit 110000 "DMTObjMgt"
{
    procedure LookUpOldVersionTable(var DMTTable: Record DMTTable) OK: Boolean;
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        DMTSetup: Record "DMTSetup";
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        DMTSelectTables: Page DMTSelectTables;
    begin
        DMTSetup.CheckSchemaInfoHasBeenImporterd();
        DMTFieldBuffer.FindSet();
        repeat
            if not TempAllObjWithCaption.Get(TempAllObjWithCaption."Object Type"::Table, DMTFieldBuffer.TableNo) then begin
                TempAllObjWithCaption."Object Type" := TempAllObjWithCaption."Object Type"::Table;
                TempAllObjWithCaption."Object ID" := DMTFieldBuffer.TableNo;
                TempAllObjWithCaption."Object Name" := DMTFieldBuffer.TableName;
                TempAllObjWithCaption."Object Caption" := DMTFieldBuffer."Table Caption";
                TempAllObjWithCaption.Insert(false);
            end;
        until DMTFieldBuffer.Next() = 0;
        if TempAllObjWithCaption.FindFirst() then;
        DMTSelectTables.Set(TempAllObjWithCaption);
        DMTSelectTables.LookupMode(true);
        if DMTSelectTables.RunModal() = Action::LookupOK then begin
            DMTSelectTables.GetSelection(TempAllObjWithCaption);
            DMTTable."NAV Src.Table No." := TempAllObjWithCaption."Object ID";
            DMTTable."NAV Src.Table Caption" := TempAllObjWithCaption."Object Caption";
        end;
    end;

    procedure LookUpToTable(var DMTTable: Record DMTTable) OK: Boolean;
    var
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        DMTSelectTables: Page DMTSelectTables;
    begin
        LoadTableList(TempAllObjWithCaption);
        if TempAllObjWithCaption.FindFirst() then;
        DMTSelectTables.Set(TempAllObjWithCaption);
        DMTSelectTables.LookupMode(true);
        if DMTSelectTables.RunModal() = Action::LookupOK then begin
            DMTSelectTables.GetSelection(TempAllObjWithCaption);
            DMTTable."Target Table ID" := TempAllObjWithCaption."Object ID";
            DMTTable."Target Table Caption" := TempAllObjWithCaption."Object Caption";
        end;
    end;

    procedure AddSelectedTables() OK: Boolean;
    var
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        DMTField: Record DMTField;
        DMTTable: Record DMTTable;
        File: Record File;
        DMTSelectTables: Page DMTSelectTables;
    begin
        LoadTableList(TempAllObjWithCaption);
        if TempAllObjWithCaption.FindFirst() then;
        DMTSelectTables.Set(TempAllObjWithCaption);
        DMTSelectTables.LookupMode(true);
        if DMTSelectTables.RunModal() = Action::LookupOK then begin
            DMTSelectTables.GetSelection(TempAllObjWithCaption);
            if TempAllObjWithCaption.FindSet() then
                repeat
                    if not DMTTable.get(TempAllObjWithCaption."Object ID") then begin
                        Clear(DMTTable);
                        DMTTable.Validate("NAV Src.Table Caption", Format(TempAllObjWithCaption."Object ID"));
                        DMTTable.Insert();
                        if DMTTable.TryFindExportDataFile() then begin
                            if DMTTable.FindFileRec(File) then
                                // lager than 100KB -> CSV
                                if ((File.Size / 1024) < 100) then
                                    DMTTable.Validate(BufferTableType, DMTTable.BufferTableType::"Generic Buffer Table for all Files")
                                else
                                    DMTTable.Validate(BufferTableType, DMTTable.BufferTableType::"Seperate Buffer Table per CSV");
                            DMTTable.Validate("Data Source Type", DMTTable."Data Source Type"::"NAV CSV Export");
                            DMTTable.Modify();
                        end;
                        DMTField.InitForTargetTable(DMTTable);
                    end;
                until TempAllObjWithCaption.Next() = 0;
        end;
    end;

    local procedure LoadTableList(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.FindSet();
        repeat
            TempAllObjWithCaption := AllObjWithCaption;
            TempAllObjWithCaption.Insert(false);
        until AllObjWithCaption.Next() = 0;
    end;

    internal procedure ValidateFromTableCaption(var Rec: Record DMTTable; xRec: Record DMTTable)
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if rec."NAV Src.Table Caption" = xRec."NAV Src.Table Caption" then
            exit;
        if rec."NAV Src.Table Caption" = '' then
            exit;
        // IsNumber
        if Delchr(rec."NAV Src.Table Caption", '=', '0123456789') = '' then begin
            if DMTFieldBuffer.IsEmpty then begin
                evaluate(rec."Target Table ID", rec."NAV Src.Table Caption");
                if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, Rec."Target Table ID") then
                    Rec."Target Table Caption" := AllObjWithCaption."Object Caption";
            end else begin
                DMTFieldBuffer.SetFilter(TableNo, rec."NAV Src.Table Caption");
                if DMTFieldBuffer.FindFirst() then begin
                    Rec."NAV Src.Table No." := DMTFieldBuffer.TableNo;
                    Rec."NAV Src.Table Caption" := DMTFieldBuffer."Table Caption";
                end;
            end;
        end;
    end;

    internal procedure ValidateToTableCaption(var Rec: Record DMTTable; xRec: Record DMTTable)
    var
        allObjWithCaption: Record AllObjWithCaption;
    begin
        if rec."Target Table Caption" = xRec."Target Table Caption" then
            exit;
        if rec."Target Table Caption" = '' then
            exit;
        // IsNumber
        if Delchr(rec."Target Table Caption", '=', '0123456789') = '' then begin
            if allObjWithCaption.get(allObjWithCaption."Object Type"::Table, Rec."Target Table Caption") then begin
                Rec."Target Table ID" := allObjWithCaption."Object ID";
                Rec."Target Table Caption" := allObjWithCaption."Object Caption";
            end;
        end;
    end;

    procedure ImportNAVSchemaFile()
    var
        DMTSetup: Record "DMTSetup";
        TempBlob: Codeunit "Temp Blob";
        FieldImport: XmlPort DMTFieldBufferImport;
        ServerFile: File;
        InStr: InStream;
        FileName: Text;
        FileFound: Boolean;
        ImportFinishedMsg: Label 'Import finished', comment = 'Import abgeschlossen';
    begin
        if DMTSetup.Get() and (DMTSetup."Schema.csv File Path" <> '') then
            if ServerFile.Open(DMTSetup."Schema.csv File Path") then begin
                ServerFile.CreateInStream(InStr);
                FileFound := true;
            end;

        if not FileFound then begin
            TempBlob.CreateInStream(InStr);
            if not UploadIntoStream('Select a Schema.csv file', '', format(Enum::DMTFileFilter::CSV), FileName, InStr) then begin
                exit;
            end;
        end;
        FieldImport.SetSource(InStr);
        FieldImport.Import();
        Message(ImportFinishedMsg);
    end;

    procedure CreateListOfAvailableObjectIDsInLicense(ObjectType: Enum DMTObjTypes; var ObjectIDsAvailable: List of [Integer]; IgnoreFilters: Boolean) NoOfObjects: Integer
    var
        AllObjWithCaption: Record AllObjWithCaption;
        DMTSetup: Record DMTSetup;
        LicensePermission: Record "License Permission";
        PermissionRange: Record "Permission Range";
        SessionStorage: Codeunit DMTSessionStorage;
        PermRangeIDFilter: Text;
    begin

        Clear(ObjectIDsAvailable);
        DMTSetup.GetRecordOnce();

        // Collect Object IDs in License
        case ObjectType of
            ObjectType::Table:
                begin
                    PermissionRange.SetFilter("To", '50000..99999|130000..149999');
                    PermissionRange.SetRange("Object Type", PermissionRange."Object Type"::Table);
                    PermissionRange.SetRange("Insert Permission", PermissionRange."Insert Permission"::Yes);

                    LicensePermission.SetRange("Object Type", LicensePermission."Object Type"::Table);
                    LicensePermission.SetRange("Insert Permission", LicensePermission."Insert Permission"::Yes);
                    if not IgnoreFilters then
                        if (DMTSetup."Obj. ID Range Buffer Tables" <> '') then
                            LicensePermission.SetFilter("Object Number", DMTSetup."Obj. ID Range Buffer Tables")
                        else
                            LicensePermission.SetFilter("Object Number", '50000..99999|130000..149999');
                end;
            ObjectType::XMLPort:
                begin
                    PermissionRange.SetFilter("To", '50000..99999|130000..149999');
                    PermissionRange.SetRange("Object Type", PermissionRange."Object Type"::Table);
                    PermissionRange.SetRange("Insert Permission", PermissionRange."Insert Permission"::Yes);
                    PermissionRange.SetRange("Execute Permission", PermissionRange."Execute Permission"::Yes);

                    LicensePermission.SetRange("Object Type", LicensePermission."Object Type"::XMLport);
                    LicensePermission.SetRange("Insert Permission", LicensePermission."Insert Permission"::Yes);
                    LicensePermission.SetRange("Execute Permission", LicensePermission."Execute Permission"::Yes);
                    if not IgnoreFilters then
                        if (DMTSetup."Obj. ID Range XMLPorts" <> '') then
                            LicensePermission.SetFilter("Object Number", DMTSetup."Obj. ID Range XMLPorts")
                        else
                            LicensePermission.SetFilter("Object Number", '50000..99999|130000..149999');
                end;
        end;
        if not SessionStorage.GetLicenseInfo(ObjectIDsAvailable, ObjectType) then begin

            if PermissionRange.FindSet(false, false) then
                repeat
                    PermRangeIDFilter += StrSubstNo('%1..%2|', PermissionRange.From, PermissionRange."To");
                until PermissionRange.Next() = 0;
            PermRangeIDFilter := PermRangeIDFilter.TrimEnd('|');
            if PermRangeIDFilter <> '' then begin
                LicensePermission.FilterGroup(2);
                LicensePermission.SetFilter("Object Number", PermRangeIDFilter);
                LicensePermission.FilterGroup(0);
            end;

            if LicensePermission.FindSet() then begin
                repeat
                    if AllObjWithCaption.Get(LicensePermission."Object Type", LicensePermission."Object Number") then begin
                        if IsGeneratedAppObject(AllObjWithCaption) then
                            ObjectIDsAvailable.Add(LicensePermission."Object Number");
                    end else begin
                        ObjectIDsAvailable.Add(LicensePermission."Object Number");
                    end;
                until LicensePermission.Next() = 0;
            end;
            SessionStorage.SetLicenseInfo(ObjectType, ObjectIDsAvailable);
        end;
        NoOfObjects := ObjectIDsAvailable.Count;
    end;

    procedure GetAvailableObjectIDsInLicenseFilter(ObjectType: Enum DMTObjTypes; IgnoreFilters: Boolean) ObjIDFilter: Text
    var
        TempInteger: Record Integer temporary;
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
        Number: Integer;
        ObjectIDsAvailable: List of [Integer];
    begin
        if CreateListOfAvailableObjectIDsInLicense(ObjectType, ObjectIDsAvailable, IgnoreFilters) = 0 then
            exit('');
        foreach Number in ObjectIDsAvailable do begin
            TempInteger.Number := Number;
            TempInteger.Insert();
        end;
        Number := TempInteger.Count;
        RecRef.GetTable(TempInteger);
        ObjIDFilter := SelectionFilterManagement.GetSelectionFilter(RecRef, TempInteger.FieldNo(Number));
    end;

    local procedure IsCoreAppObject(AllObjWithCaption: Record AllObjWithCaption) IsCoreAppObj: Boolean
    begin
        case AllObjWithCaption."Object Type" of
            allObjWithCaption."Object Type"::Table:
                begin
                    IsCoreAppObj := allObjWithCaption."Object ID" in [Database::DMTSetup,
                                                                      Database::DMTTable,
                                                                      Database::DMTField,
                                                                      Database::DMTErrorLog,
                                                                      Database::DMTExportObject,
                                                                      Database::DMTFieldBuffer,
                                                                      Database::DMTTask,
                                                                      Database::DMTDataSourceHeader,
                                                                      Database::DMTGenBuffTable,
                                                                      Database::DMTDataSourceLine,
                                                                      Database::DMTReplacementsHeader,
                                                                      Database::DMTReplacementsLine];
                end;
            allObjWithCaption."Object Type"::XMLport:
                begin
                    IsCoreAppObj := allObjWithCaption."Object ID" in [Xmlport::DMTFieldBufferImport,
                                                                      Xmlport::DMTGenBuffImport];
                end;
        end;
    end;

    local procedure IsGeneratedAppObject(AllObjWithCaption: Record AllObjWithCaption) Result: Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        mI: ModuleInfo;
    begin
        if IsCoreAppObject(AllObjWithCaption) then exit(false);

        NavApp.GetCurrentModuleInfo(mI);
        NAVAppInstalledApp.SetRange("App ID", mI.Id);
        NAVAppInstalledApp.FindFirst();
        Result := (NAVAppInstalledApp."Package ID" = AllObjWithCaption."App Package ID");
    end;


}