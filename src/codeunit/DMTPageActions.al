codeunit 110010 "DMTPageActions"
{

    // Tabellen
    procedure AddSelectedTargetTables()
    var
        ObjMgt: Codeunit DMTObjMgt;
    begin
        ObjMgt.AddSelectedTables();
    end;

    procedure DeleteSelectedTargetTables(var DMTTable_Selected: Record DMTTable)
    begin
        if not (DMTTable_Selected.MarkedOnly) or not (DMTTable_Selected.FindFirst()) then
            exit;
        DMTTable_Selected.DeleteAll(true);
    end;

    procedure ImportSelectedIntoBuffer(var DMTTable_SELECTED: Record DMTTable)
    var
        DMTTable: Record DMTTable;
        Start: DateTime;
        TableStart: DateTime;
        Progress: Dialog;
        FinishedMsg: Label 'Processing finished\Duration %1', Comment = 'Vorgang abgeschlossen\Dauer %1';
        ImportFilesProgressMsg: Label 'Reading files into buffer tables', Comment = 'Dateien werden eingelesen';
        ProgressMsg: Text;
    begin
        DMTTable_SELECTED.SetCurrentKey("Sort Order");
        ProgressMsg := '==========================================\' +
                       ImportFilesProgressMsg + '\' +
                       '==========================================\';

        DMTTable_SELECTED.FindSet(false, false);
        REPEAT
            ProgressMsg += '\' + DMTTable_SELECTED."Target Table Caption" + '    ###########################' + FORMAT(DMTTable_SELECTED."Target Table ID") + '#';
        UNTIL DMTTable_SELECTED.NEXT() = 0;

        DMTTable_SELECTED.FindSet();
        Start := CurrentDateTime;
        Progress.Open(ProgressMsg);
        repeat
            TableStart := CurrentDateTime;
            DMTTable := DMTTable_SELECTED;
            Progress.Update(DMTTable_SELECTED."Target Table ID", 'Wird eingelesen');
            DMTTable.ImportToBufferTable();
            Commit();
            Progress.Update(DMTTable_SELECTED."Target Table ID", CURRENTDATETIME - TableStart);
        until DMTTable_SELECTED.Next() = 0;
        Progress.Close();
        Message(FinishedMsg, CurrentDateTime - Start);
    end;

    procedure DownloadAllALDataMigrationObjects()
    var
        DMTTable: Record DMTTable;
        DataCompression: Codeunit "Data Compression";
        ObjGen: Codeunit DMTObjectGenerator;
        FileBlob: Codeunit "Temp Blob";
        IStr: InStream;
        OStr: OutStream;
        toFileName: text;
        DefaultTextEncoding: TextEncoding;
    begin
        DefaultTextEncoding := TextEncoding::UTF8;
        // DefaultTextEncoding := TextEncoding::MSDos;
        // DefaultTextEncoding := TextEncoding::UTF16;
        // DefaultTextEncoding := TextEncoding::Windows;
        DMTTable.SetRange(BufferTableType, DMTTable.BufferTableType::"Seperate Buffer Table per CSV");
        if DMTTable.FindSet() then begin
            DataCompression.CreateZipArchive();
            repeat
                //Table
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
                OStr.WriteText(ObjGen.CreateALTable(DMTTable).ToText());
                FileBlob.CreateInStream(IStr, DefaultTextEncoding);
                DataCompression.AddEntry(IStr, DMTTable.GetALBufferTableName());
                //XMLPort
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
                OStr.WriteText(ObjGen.CreateALXMLPort(DMTTable).ToText());
                FileBlob.CreateInStream(IStr, DefaultTextEncoding);
                DataCompression.AddEntry(IStr, DMTTable.GetALXMLPortName());
            until DMTTable.Next() = 0;
        end;
        Clear(FileBlob);
        FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
        DataCompression.SaveZipArchive(OStr);
        FileBlob.CreateInStream(IStr, DefaultTextEncoding);
        toFileName := 'BufferTablesAndXMLPorts.zip';
        DownloadFromStream(iStr, 'Download', 'ToFolder', format(Enum::DMTFileFilter::ZIP), toFileName);
    end;

    internal procedure RenewObjectIdAssignments()
    var
        DMTTable: Record DMTTable;
    begin
        DMTTable.SetRange(BufferTableType, DMTTable.BufferTableType::"Seperate Buffer Table per CSV");
        if DMTTable.FindSet() then
            repeat
                DMTTable.TryFindBufferTableID(true);
                DMTTable.TryFindXMLPortID(true);
            until DMTTable.Next() = 0;
    end;

    internal procedure ImportSelectedIntoTarget(DMTTable_SELECTED: Record DMTTable)
    var
        DMTTable: Record DMTTable;
        DMTImport: Codeunit "DMTImport";
    begin
        if not (DMTTable_Selected.MarkedOnly) or not (DMTTable_Selected.FindFirst()) then
            exit;
        DMTTable_SELECTED.SetCurrentKey("Sort Order");
        DMTTable_SELECTED.FindSet();
        repeat
            DMTTable := DMTTable_SELECTED;
            DMTImport.StartImport(DMTTable, true, false);
        until DMTTable_SELECTED.Next() = 0;
    end;

    procedure ProposeMatchingFields(var DMTField: Record DMTField)
    var
        DMTTable: Record DMTTable;
    begin
        DMTTable.Get(DMTField.GetRangeMin(DMTField."Target Table ID"));
        ProposeMatchingFields(DMTTable);
    end;

    procedure ProposeMatchingFieldsForSelection(var DMTTable_Selected: Record DMTTable)
    var
        DMTField: Record DMTField;
    begin
        if not (DMTTable_Selected.MarkedOnly) or not (DMTTable_Selected.FindFirst()) then
            exit;
        DMTTable_Selected.FindSet();
        repeat
            ProposeMatchingFields(DMTTable_Selected);
            DMTField.AssignSourceToTargetFields(DMTTable_Selected);
            DMTField.ProposeValidationRules(DMTTable_Selected);
        until DMTTable_Selected.Next() = 0;
    end;

    procedure ProposeMatchingFields(DMTTable: Record DMTTable)
    var
        DMTField: Record DMTField;
    begin
        DMTField.AssignSourceToTargetFields(DMTTable);
        DMTField.ProposeValidationRules(DMTTable);
    end;
    // - Add Target Tables
    // - Delete Target Table Setup
    // Objekte
    // - ExportALObjects
    // - RenumberALObjects (ObjekteRange)
    // - RenewObjectIdAssignments (Vorhandene Finden)
    // Migration
    // - ImportToBufferForSelected
    // - ProposeFieldDef
    // - TransferSelectedToTargetTable
    // Zusätzlich
    // - UpdateTableRelationInfo
    // - UpdateSortOrder
    // - GetToTableIDFilter
    // - GetFromTableIDFilter
    // - Task
}