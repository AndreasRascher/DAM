/*   DatenimportLine:
	Column Caption
	Column Name
	Column Type (Text, Decimal, Integer, Option,..) 
	Column Width
*/
table 91007 "DMTDataSourceHeader"
{
    fields
    {
        field(1; Code; Code[100]) { Caption='Code'; }
        field(10; Description; Text[150]) { Caption = 'Description'; }
        field(11; FilePath; Text[250]) { Caption = 'File Path',comment='Dateipfad'; }
        field(12; FileName; Text[250]) { Caption = 'File Name',comment = 'Dateiname'; }
        field(13; "Data Source Type"; Enum DMTDataSourceType) { Caption = 'Data Source Type'; }
        field(20; "NAV Schema File Status"; Option)
        {
            CaptionML = DEU = 'NAV Schema Datei Status', ENU = 'NAV Schema File Status';
            Editable = false;
            OptionMembers = "Import required",Imported;
            OptionCaptionML = ENU = '"Import required",Imported', DEU = '"Import erforderlich",Importiert';
        }
        field(21; "NAV Src.Table No."; Integer) { Caption = 'NAV Src.Table No.'; }
        field(22; "NAV Src.Table Name"; Text[250]) { Caption = 'NAV Source Table Name'; }
        field(23; "NAV Src.Table Caption"; Text[250]) { Caption = 'NAV Source Table Caption'; }
        field(30; "CSV Field Delimiter"; Text[50]) { Caption = 'CSV Field Delimiter'; InitValue = '<None>'; }
        field(31; "CSV Field Seperator"; Text[50]) { Caption = 'CSV Field Seperator'; InitValue = '<TAB>'; }
        field(32; "CSV Record Seperator"; Text[50]) { Caption = 'CSV Record Seperator'; InitValue = '<NewLine>'; }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }

    trigger OnInsert()
    var
        FieldBuffer: Record DMTFieldBuffer;
    begin
        if not FieldBuffer.IsEmpty then
            Rec."NAV Schema File Status" := Rec."NAV Schema File Status"::Imported;
    end;

    trigger OnDelete()
    var
        DataSourceLine: Record DMTDataSourceLine;
    begin
        if DataSourceLine.FilterFor(Rec) then
            DataSourceLine.DeleteAll(true);
    end;

}