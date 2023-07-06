codeunit 73022 DMTImportFileMgt
{
    procedure ImportPreviewWithUpload(dataFile: Record DMTDataFile; FromLineNo: Integer; ToLineNo: Integer)
    var
        fileConfig: Record DMTFileConfig;
        importFileMgt: Codeunit DMTImportFileMgt;
        readStream: InStream;
    begin
        dataFile.TestField("File Config Code");
        fileConfig.Get(dataFile."File Config Code");
        importFileMgt.GetReadStreamFromUpload(readStream, fileConfig.GetTextEncoding());
        importFileMgt.ImportCSVFomStream(readStream);
    end;

    procedure ImportPreviewFromFilePath(dataFile: Record DMTDataFile; FromLineNo: Integer; ToLineNo: Integer)
    var
        fileConfig: Record DMTFileConfig;
        importFileMgt: Codeunit DMTImportFileMgt;
        readStream: InStream;
    begin
        dataFile.TestField("File Config Code");
        fileConfig.Get(dataFile."File Config Code");
        importFileMgt.GetReadStreamFromFileFromPath(readStream, dataFile, fileConfig.GetTextEncoding());
        importFileMgt.ImportCSVFomStream(readStream);
    end;

    procedure GetReadStreamFromFileFromPath(var readStream: InStream; dataFile: Record DMTDataFile; encoding: TextEncoding)
    var
        File: File;
        isEOS: Boolean;
    begin
        Clear(readStream);
        File.Open(dataFile.FullDataFilePath(), encoding);
        File.CreateInStream(readStream);
        isEOS := readStream.EOS;
    end;

    procedure GetReadStreamFromUpload(var readStream: InStream; encoding: TextEncoding)
    var
        tempBlob: Codeunit "Temp Blob";
        selectCSVFileLbl: Label 'Select a csv file', Comment = 'de-De=Wählen sie eine CSV Datei aus';
        fileName: Text;
    begin
        tempBlob.CreateInStream(readStream, encoding);
        UploadIntoStream(selectCSVFileLbl, '', Format(Enum::DMTFileFilter::CSV), fileName, readStream);
        // if UploadIntoStream(selectCSVFileLbl, '', Format(Enum::DMTFileFilter::CSV), fileName, readStream) then begin
        //     exit;
        // end;
    end;

    internal procedure SetCSVProperties(Rec: Record DMTFileConfig)
    begin
        TextEncodingGlobal := Rec.GetTextEncoding();
        FieldDelimiterGlobal := Rec."CSV Field Delimiter";
        FieldSeparatorGlobal := Rec."CSV Field Separator";
        RecordSeparatorGlobal := Rec."CSV Record Separator";
    end;

    internal procedure ImportCSVFomStream(var readstream: InStream)
    begin
        CSVImport.SetSource(readstream);
        CSVImport.TextEncoding := TextEncodingGlobal;
        CSVImport.FieldDelimiter := FieldDelimiterGlobal;
        CSVImport.FieldSeparator := FieldSeparatorGlobal;
        CSVImport.RecordSeparator := RecordSeparatorGlobal;
        CSVImport.Import();
    end;

    procedure DefineLinesToImport(LineNo: Integer)
    begin
        CSVImport.SetOrAddSpecificImportLineNo(LineNo);
    end;

    var
        CSVImport: XmlPort DMTCSVImport;
        TextEncodingGlobal: TextEncoding;
        FieldDelimiterGlobal, FieldSeparatorGlobal, RecordSeparatorGlobal : Text;

}