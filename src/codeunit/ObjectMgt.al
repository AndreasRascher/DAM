codeunit 91004 ObjMgt
{
    procedure LookUpOldVersionTable(var DAMTable: Record DAMTable) OK: Boolean;
    var
        DAMFieldBuffer: Record DAMFieldBuffer;
        DAMSetup: Record "DAM Object Setup";
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        DAMSelectTables: Page DAMSelectTables;
    begin
        DAMSetup.CheckSchemaInfoHasBeenImporterd();
        DAMFieldBuffer.FindSet();
        repeat
            if not TempAllObjWithCaption.Get(TempAllObjWithCaption."Object Type"::Table, DAMFieldBuffer.TableNo) then begin
                TempAllObjWithCaption."Object Type" := TempAllObjWithCaption."Object Type"::Table;
                TempAllObjWithCaption."Object ID" := DAMFieldBuffer.TableNo;
                TempAllObjWithCaption."Object Name" := DAMFieldBuffer.TableName;
                TempAllObjWithCaption."Object Caption" := DAMFieldBuffer."Table Caption";
                TempAllObjWithCaption.Insert(false);
            end;
        until DAMFieldBuffer.Next() = 0;
        if TempAllObjWithCaption.FindFirst() then;
        DAMSelectTables.Set(TempAllObjWithCaption);
        DAMSelectTables.LookupMode(true);
        if DAMSelectTables.RunModal() = Action::LookupOK then begin
            DAMSelectTables.GetSelection(TempAllObjWithCaption);
            DAMTable."Old Version Table ID" := TempAllObjWithCaption."Object ID";
            DAMTable."Old Version Table Caption" := TempAllObjWithCaption."Object Caption";
        end;
    end;

    procedure LookUpToTable(var DAMTable: Record DAMTable) OK: Boolean;
    var
        AllObjWithCaption: Record AllObjWithCaption;
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        DAMSelectTables: Page DAMSelectTables;
    begin
        LoadTableList(TempAllObjWithCaption);
        if TempAllObjWithCaption.FindFirst() then;
        DAMSelectTables.Set(TempAllObjWithCaption);
        DAMSelectTables.LookupMode(true);
        if DAMSelectTables.RunModal() = Action::LookupOK then begin
            DAMSelectTables.GetSelection(TempAllObjWithCaption);
            DAMTable."To Table ID" := TempAllObjWithCaption."Object ID";
            DAMTable."To Table Caption" := TempAllObjWithCaption."Object Caption";
        end;
    end;

    procedure AddSelectedTables() OK: Boolean;
    var
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        DAMSelectTables: Page DAMSelectTables;
        DAMTable: Record DAMTable;
    begin
        LoadTableList(TempAllObjWithCaption);
        if TempAllObjWithCaption.FindFirst() then;
        DAMSelectTables.Set(TempAllObjWithCaption);
        DAMSelectTables.LookupMode(true);
        if DAMSelectTables.RunModal() = Action::LookupOK then begin
            DAMSelectTables.GetSelection(TempAllObjWithCaption);
            if TempAllObjWithCaption.FindSet() then
                repeat
                    if not DAMTable.get(TempAllObjWithCaption."Object ID") then begin
                        Clear(DAMTable);
                        DAMTable.Validate("Old Version Table Caption", Format(TempAllObjWithCaption."Object ID"));
                        DAMTable.Insert();
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

    internal procedure ValidateFromTableCaption(var Rec: Record DAMTable; xRec: Record DAMTable)
    var
        DAMFieldBuffer: Record DAMFieldBuffer;
    begin
        if rec."Old Version Table Caption" = xRec."Old Version Table Caption" then
            exit;
        if rec."Old Version Table Caption" = '' then
            exit;
        // IsNumber
        if Delchr(rec."Old Version Table Caption", '=', '0123456789') = '' then begin
            DAMFieldBuffer.SetFilter(TableNo, rec."Old Version Table Caption");
            if DAMFieldBuffer.FindFirst() then begin
                Rec."Old Version Table ID" := DAMFieldBuffer.TableNo;
                Rec."Old Version Table Caption" := DAMFieldBuffer."Table Caption";
            end;
        end;
    end;

    internal procedure ValidateToTableCaption(var Rec: Record DAMTable; xRec: Record DAMTable)
    var
        DAMFieldBuffer: Record DAMFieldBuffer;
    begin
        if rec."To Table Caption" = xRec."To Table Caption" then
            exit;
        if rec."To Table Caption" = '' then
            exit;
        // IsNumber
        if Delchr(rec."To Table Caption", '=', '0123456789') = '' then begin
            DAMFieldBuffer.SetFilter(TableNo, rec."To Table Caption");
            if DAMFieldBuffer.FindFirst() then begin
                Rec."To Table ID" := DAMFieldBuffer.TableNo;
                Rec."To Table Caption" := DAMFieldBuffer."Table Caption";
            end;

        end;
    end;

    procedure ImportNAVSchemaFile()
    var
        DAMSetup: Record "DAM Object Setup";
        FieldImport: XmlPort FieldBufferImport;
        ServerFile: File;
        InStr: InStream;
        FileName: Text;
        TempBlob: Codeunit "Temp Blob";
    begin
        if DAMSetup.Get() then
            if DAMSetup."Schema.xml File Path" <> '' then
                if ServerFile.Open(DAMSetup."Schema.xml File Path") then begin
                    ServerFile.CreateInStream(InStr);
                end else begin
                    TempBlob.CreateInStream(InStr);
                    if not UploadIntoStream('Select a Schema.XML file', '', 'Text Files|*.txt', FileName, InStr) then begin
                        exit;
                    end;
                end;
        FieldImport.SetSource(InStr);
        FieldImport.Import();
    end;
}