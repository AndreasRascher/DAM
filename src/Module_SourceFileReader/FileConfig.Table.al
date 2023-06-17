table 73011 DMTFileConfig
{
    Caption = 'DMT File Config', Locked = true;
    DataClassification = CustomerContent;
    LookupPageId = DMTFileConfigList;

    fields
    {
        field(1; Code; Code[50]) { Caption = 'Code', Comment = 'de-DE=Code'; }
        field(10; Description; Code[50]) { Caption = 'Description', Comment = 'de-DE=Beschreibung'; }
        field(11; "File Encoding"; Enum DMTEncoding) { Caption = 'de-DE=Datei-Textcodierung'; }
        field(12; "CSV Field Delimiter"; Text[50]) { Caption = 'de-DE=Feld Begrenzungszeichen'; InitValue = '<None>'; }
        field(13; "CSV Field Separator"; Text[50]) { Caption = 'de-DE=Feld Trennzeichen'; InitValue = ','; }
        // <None>	There is no field separator.
        // <NewLine>	Any combination of CR and LF characters.
        // <CR/LF>	CR followed by LF.
        // <CR>	CR alone.
        // <LF>	LF alone.
        // <TAB>	Tabulator alone.
        field(14; "CSV Record Separator"; Text[50]) { Caption = 'de-DE=Datensatz Trennzeichen'; }
        field(20; "Header Line No."; Integer) { Caption = 'de-DE=Zeilennr. der Überschrift'; BlankZero = true; }
        field(21; "No. of Columns"; Integer) { Caption = 'No. of Columns', Comment = 'de-DE=Anzahl Spalten'; }
        field(22; "Key Field Col.Numbers"; Text[250]) { Caption = 'Key field column numbers'; }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }

    procedure GetTextEncoding(): TextEncoding
    begin
        case Rec."File Encoding" of
            Rec."File Encoding"::"MS-DOS":
                exit(TextEncoding::MSDos);
            Rec."File Encoding"::"UTF-8":
                exit(TextEncoding::UTF8);
            Rec."File Encoding"::"UTF-16":
                exit(TextEncoding::UTF16);
            Rec."File Encoding"::WINDOWS:
                exit(TextEncoding::Windows);
        end;
    end;
}