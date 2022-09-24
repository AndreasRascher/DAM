codeunit 110000 "DMTObjMgt"
{
    procedure LookUpOldVersionTable(var NAVSrcTableNo: Integer; var NAVSrcTableCaption: Text) OK: Boolean;
    var
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        DMTSetup: Record "DMTSetup";
        DMTSelectTables: Page "DMTSelectTableList";
        DMTFieldBufferQry: Query DMTFieldBufferQry;
    begin
        DMTSetup.CheckSchemaInfoHasBeenImporterd();
        DMTFieldBufferQry.Open();
        while DMTFieldBufferQry.Read() do begin
            TempAllObjWithCaption."Object Type" := TempAllObjWithCaption."Object Type"::Table;
            TempAllObjWithCaption."Object ID" := DMTFieldBufferQry.TableNo;
            TempAllObjWithCaption."Object Name" := DMTFieldBufferQry.TableName;
            TempAllObjWithCaption."Object Caption" := DMTFieldBufferQry.Table_Caption;
            TempAllObjWithCaption.Insert(false);
        end;
        if TempAllObjWithCaption.FindFirst() then;
        DMTSelectTables.Set(TempAllObjWithCaption, false);
        DMTSelectTables.LookupMode(true);
        if DMTSelectTables.RunModal() = Action::LookupOK then begin
            DMTSelectTables.GetSelection(TempAllObjWithCaption);
            NAVSrcTableNo := TempAllObjWithCaption."Object ID";
            NAVSrcTableCaption := TempAllObjWithCaption."Object Caption";
            exit(true);
        end;
    end;

    procedure LookUpTargetTable(var DMTTable: Record DMTTable) OK: Boolean;
    var
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        DMTSelectTables: Page "DMTSelectTableList";
    begin
        LoadTableList(TempAllObjWithCaption);
        if TempAllObjWithCaption.FindFirst() then;
        DMTSelectTables.Set(TempAllObjWithCaption, true);
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
        DMTTable: Record DMTTable;
        DMTSelectTables: Page "DMTSelectTableList";
    begin
        LoadTableList(TempAllObjWithCaption);
        if TempAllObjWithCaption.FindFirst() then;
        DMTSelectTables.Set(TempAllObjWithCaption, true);
        DMTSelectTables.LookupMode(true);
        if DMTSelectTables.RunModal() = Action::LookupOK then begin
            DMTSelectTables.GetSelection(TempAllObjWithCaption);
            if TempAllObjWithCaption.FindSet() then
                repeat
                    if not DMTTable.get(TempAllObjWithCaption."Object ID") then begin
                        AddNewTargetTable(TempAllObjWithCaption."Object ID", DMTTable);
                    end;
                until TempAllObjWithCaption.Next() = 0;
        end;
    end;

    local procedure LoadTableList(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        DMTTable: Record DMTTable;
        TableMeta: Record "Table Metadata";
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.FindSet();
        repeat
            TempAllObjWithCaption := AllObjWithCaption;
            TempAllObjWithCaption."Object Subtype" := '';
            if DMTTable.Get(TempAllObjWithCaption."Object ID") then
                TempAllObjWithCaption."Object Subtype" += 'TableExists';
            if TableMeta.Get(TempAllObjWithCaption."Object ID") then begin
                if TableMeta.ObsoleteState = TableMeta.ObsoleteState::Pending then
                    TempAllObjWithCaption."Object Subtype" += 'Pending';
                if TableMeta.ObsoleteState = TableMeta.ObsoleteState::Pending then
                    TempAllObjWithCaption."Object Subtype" += 'Removed';
            end;
            TempAllObjWithCaption.Insert(false);
        until AllObjWithCaption.Next() = 0;
    end;

    internal procedure ValidateFromTableCaption(var Rec: Record DMTTable; xRec: Record DMTTable)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        DMTFieldBuffer: Record DMTFieldBuffer;
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

    internal procedure ValidateTargetTableCaption(var Rec: Record DMTTable; xRec: Record DMTTable)
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
        FileFound: Boolean;
        ServerFile: File;
        InStr: InStream;
        ImportFinishedMsg: Label 'Import finished', comment = 'Import abgeschlossen';
        FileName: Text;
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

    procedure SetNAVTableCaptionAndTableName(SourceTableID: Integer; var NAVSrcTableCaption: Text[250]; var NAVSrcTableName: Text[250])
    var
        DMTFieldBufferQry: Query DMTFieldBufferQry;
    begin
        if SourceTableID = 0 then exit;
        Clear(NAVSrcTableCaption);
        Clear(NAVSrcTableName);
        DMTFieldBufferQry.SetRange(TableNo, SourceTableID);
        DMTFieldBufferQry.Open();
        if DMTFieldBufferQry.Read() then begin
            NAVSrcTableCaption := DMTFieldBufferQry.Table_Caption;
            NAVSrcTableName := DMTFieldBufferQry.TableName;
        end;
    end;

    procedure AddNewTargetTable(TableID: Integer; var DMTTable: Record DMTTable)
    begin
        AddNewTargetTable(TableID, TableID, '', '', DMTTable);
    end;

    procedure AddNewTargetTable(SourceTableID: Integer; TargetTableID: Integer; FolderPath: Text; FileName: Text; var DMTTable: Record DMTTable)
    var
        DMTField: Record DMTField;
        File: Record File;
        TableMeta: Record "Table Metadata";
    begin
        Clear(DMTTable);
        if (TargetTableID = 0) and (SourceTableID <> 0) then
            TargetTableID := SourceTableID;
        If DMTTable.Get(TargetTableID) then
            exit;

        // Target Infos
        DMTTable."Target Table ID" := TargetTableID;
        TableMeta.Get(TargetTableID);
        DMTTable."Target Table Caption" := TableMeta.Caption;

        // Find NAV Source Infos   
        DMTTable."NAV Src.Table No." := SourceTableID;
        SetNAVTableCaptionAndTableName(SourceTableID, DMTTable."NAV Src.Table Caption", DMTTable."NAV Src.Table Name");
        DMTTable.Insert();

        if DMTTable.TryFindExportDataFile() then begin
            if DMTTable.FindFileRec(File) then
                // lager than 100KB -> CSV
                if ((File.Size / 1024) < 100) then
                    DMTTable.Validate(BufferTableType, DMTTable.BufferTableType::"Generic Buffer Table for all Files")
                else
                    DMTTable.Validate(BufferTableType, DMTTable.BufferTableType::"Seperate Buffer Table per CSV");
            DMTTable.Validate("Data Source Type", DMTTable."Data Source Type"::"NAV CSV Export");
        end;
        DMTTable.ProposeObjectIDs(false);
        DMTTable.Modify();
        // Fields
        DMTField.InitForTargetTable(DMTTable);
    end;


}