codeunit 91004 "DMTObjMgt"
{
    procedure LookUpOldVersionTable(var DMTTable: Record DMTTable) OK: Boolean;
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        DMTSetup: Record "DMT Setup";
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
            DMTTable."Old Version Table ID" := TempAllObjWithCaption."Object ID";
            DMTTable."Old Version Table Caption" := TempAllObjWithCaption."Object Caption";
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
            DMTTable."To Table ID" := TempAllObjWithCaption."Object ID";
            DMTTable."To Table Caption" := TempAllObjWithCaption."Object Caption";
        end;
    end;

    procedure AddSelectedTables() OK: Boolean;
    var
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        DMTTable: Record DMTTable;
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
                        DMTTable.Validate("Old Version Table Caption", Format(TempAllObjWithCaption."Object ID"));
                        DMTTable.Insert();
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
    begin
        if rec."Old Version Table Caption" = xRec."Old Version Table Caption" then
            exit;
        if rec."Old Version Table Caption" = '' then
            exit;
        // IsNumber
        if Delchr(rec."Old Version Table Caption", '=', '0123456789') = '' then begin
            DMTFieldBuffer.SetFilter(TableNo, rec."Old Version Table Caption");
            if DMTFieldBuffer.FindFirst() then begin
                Rec."Old Version Table ID" := DMTFieldBuffer.TableNo;
                Rec."Old Version Table Caption" := DMTFieldBuffer."Table Caption";
            end;
        end;
    end;

    internal procedure ValidateToTableCaption(var Rec: Record DMTTable; xRec: Record DMTTable)
    var
        allObjWithCaption: Record AllObjWithCaption;
    begin
        if rec."To Table Caption" = xRec."To Table Caption" then
            exit;
        if rec."To Table Caption" = '' then
            exit;
        // IsNumber
        if Delchr(rec."To Table Caption", '=', '0123456789') = '' then begin
            if allObjWithCaption.get(allObjWithCaption."Object Type"::Table, Rec."To Table Caption") then begin
                Rec."To Table ID" := allObjWithCaption."Object ID";
                Rec."To Table Caption" := allObjWithCaption."Object Caption";
            end;
        end;
    end;

    procedure ImportNAVSchemaFile()
    var
        DMTSetup: Record "DMT Setup";
        TempBlob: Codeunit "Temp Blob";
        FieldImport: XmlPort FieldBufferImport;
        ServerFile: File;
        InStr: InStream;
        FileName: Text;
        FileFound: Boolean;
    begin
        if DMTSetup.Get() and (DMTSetup."Schema.xml File Path" <> '') then
            if ServerFile.Open(DMTSetup."Schema.xml File Path") then begin
                ServerFile.CreateInStream(InStr);
                FileFound := true;
            end;

        if not FileFound then begin
            TempBlob.CreateInStream(InStr);
            if not UploadIntoStream('Select a Schema.csv file', '', 'CSV Files|*.csv', FileName, InStr) then begin
                exit;
            end;
        end;

        FieldImport.SetSource(InStr);
        FieldImport.Import();
        Message('Import abgeschlossen');
    end;
}