codeunit 73022 DMTImportFileMgt
{
    procedure ImportPreview(DMTDataFile: Record DMTDataFile; FromLineNo: Integer; ToLineNo: Integer)
    begin
        DMTDataFile.TestField("File Config Code");
    end;

    procedure GetReadStreamForFileFromPath(var ReadStream: InStream; DataFile: Record DMTDataFile; encoding: TextEncoding)
    var
        File: File;
    begin
        File.Open(DataFile.FullDataFilePath(), encoding);
        File.CreateInStream(ReadStream);
    end;

    procedure GetReadStreamFromUpload(var readStream: InStream; encoding: TextEncoding)
    var
        tempBlob: Codeunit "Temp Blob";
        selectCSVFileLbl: Label 'Select a csv file', Comment = 'de-De=Wählen sie eine CSV Datei aus';
        fileName: Text;
    begin
        tempBlob.CreateInStream(readStream, encoding);
        if not UploadIntoStream(selectCSVFileLbl, '', Format(Enum::DMTFileFilter::CSV), fileName, readStream) then begin
            exit;
        end;
    end;

    internal procedure SetCSVProperties(Rec: Record DMTFileConfig)
    begin
        TextEncodingGlobal := Rec.GetTextEncoding();
        FieldDelimiterGlobal := Rec."CSV Field Delimiter";
        FieldSeparatorGlobal := Rec."CSV Field Separator";
        RecordSeparatorGlobal := Rec."CSV Record Separator";
    end;

    internal procedure ImportCSV()
    var
        CSVImport: XmlPort DMTCSVImport;
    begin
        CSVImport.TextEncoding := TextEncodingGlobal;
        CSVImport.FieldDelimiter := FieldDelimiterGlobal;
        CSVImport.FieldSeparator := FieldSeparatorGlobal;
        CSVImport.RecordSeparator := RecordSeparatorGlobal;
    end;

    var

        TextEncodingGlobal: TextEncoding;
        FieldDelimiterGlobal, FieldSeparatorGlobal, RecordSeparatorGlobal : Text;
}