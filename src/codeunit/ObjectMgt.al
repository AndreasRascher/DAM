codeunit 91004 ObjMgt
{
    procedure LookUpFromTable(var DAMTable: Record DAMTable) OK: Boolean;
    var
        DAMFieldBuffer: Record DAMFieldBuffer;
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        AllObjectwithCaption: Page "All Objects with Caption";
    begin
        //if not DAMFieldBuffer.FindSet() then
        //    exit(false);
        DAMFieldBuffer.FindSet();
        repeat
            if not TempAllObjWithCaption.Get(TempAllObjWithCaption."Object Type"::Table, DAMFieldBuffer.TableNo) then begin
                TempAllObjWithCaption."Object Type" := TempAllObjWithCaption."Object Type"::Table;
                TempAllObjWithCaption."Object ID" := DAMFieldBuffer.TableNo;
                TempAllObjWithCaption."Object Caption" := DAMFieldBuffer."Table Caption";
                TempAllObjWithCaption.Insert(false);
            end;
        until DAMFieldBuffer.Next() = 0;
        AllObjectwithCaption.SetRecord(TempAllObjWithCaption);
        AllObjectwithCaption.LookupMode(true);
        if AllObjectwithCaption.RunModal() = Action::LookupOK then begin
            AllObjectwithCaption.GetRecord(TempAllObjWithCaption);
            DAMTable."Old Version Table ID" := TempAllObjWithCaption."Object ID";
            DAMTable."From Table Caption" := TempAllObjWithCaption."Object Caption";
        end;
    end;

    procedure LookUpToTable(var DAMTable: Record DAMTable) OK: Boolean;
    var
        AllObjWithCaption: Record AllObjWithCaption;
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        AllObjectwithCaptionList: Page "All Objects with Caption";
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        if not AllObjWithCaption.FindSet() then
            exit(false);
        repeat
            TempAllObjWithCaption := AllObjWithCaption;
            TempAllObjWithCaption.Insert(false);
        until AllObjWithCaption.Next() = 0;

        AllObjectwithCaptionList.SetRecord(TempAllObjWithCaption);
        AllObjectwithCaptionList.LookupMode(true);
        if AllObjectwithCaptionList.RunModal() = Action::LookupOK then begin
            AllObjectwithCaptionList.GetRecord(TempAllObjWithCaption);
            DAMTable."To Table ID" := TempAllObjWithCaption."Object ID";
            DAMTable."To Table Caption" := TempAllObjWithCaption."Object Caption";
        end;
    end;

    internal procedure ValidateFromTableCaption(var Rec: Record DAMTable; xRec: Record DAMTable)
    var
        DAMFieldBuffer: Record DAMFieldBuffer;
    begin
        if rec."From Table Caption" = xRec."From Table Caption" then
            exit;
        if rec."From Table Caption" = '' then
            exit;
        // IsNumber
        if Delchr(rec."From Table Caption", '=', '0123456789') = '' then begin
            DAMFieldBuffer.SetFilter(TableNo, rec."From Table Caption");
            if DAMFieldBuffer.FindFirst() then begin
                Rec."Old Version Table ID" := DAMFieldBuffer.TableNo;
                Rec."From Table Caption" := DAMFieldBuffer."Table Caption";
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
        FieldImport: XmlPort FieldBufferImport;
        FileName: Text;
        InStr: InStream;
    begin
        if not UploadIntoStream('Select a Schema.XML file', '', 'Text Files|*.txt', FileName, InStr) then
            exit;
        FieldImport.SetSource(InStr);
        FieldImport.Import();
    end;
}