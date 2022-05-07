page 91008 NAVObjects
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTExportObject;

    layout
    {
        area(Content)
        {
            group(InstructionsGroup)
            {
                ShowCaption = false;
                group(InstructionsGroup2)
                {
                    CaptionML = ENU = 'Instructions', DEU = 'Anleitung';
                    label(Instructions01)
                    {
                        ApplicationArea = All;
                        CaptionML = ENU = '1. Create an empty text file.', DEU = '1. Erstellen Sie eine neue Textdatei.';
                    }
                    label(Instructions02)
                    {
                        ApplicationArea = All;
                        CaptionML = ENU = '2. Copy and paste the the source code for your NAV version into the text file.', DEU = '2. Kopieren Sie den Quellcode für ihre NAV Version in die Textdatei.';
                    }
                    label(Instructions03)
                    {
                        ApplicationArea = All;
                        CaptionML = ENU = '3. Change the object ID to a free ID in your license. Import the object into the database and compile.', DEU = '3. Ändern Sie die die Objekt ID auf eine freie ID in ihrer Lizenz. Importieren Sie das Objekt in die Datenbank und kompilieren Sie das Objekt.';
                    }
                    label(Instructions04)
                    {
                        ApplicationArea = All;
                        CaptionML = ENU = '4. Run the object to export your data as csv per table.', DEU = '4. Führen Sie das Objekt aus. Geben sie die Tabellen-IDs ein die sie exportieren wollen. Starten den Export';
                    }

                }
            }
            group(Dataport)
            {
                Caption = 'Dataport (until NAV2009)';
                field(Dataportcontent; DataportContent)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                    trigger OnValidate()
                    begin
                        ExportDataPort_SaveText(DataportContent);
                    end;
                }
            }
            group(XMLPort)
            {
                Caption = 'XMLPort (NAV2013 - BC14)';
                field(XMLPortContent; XMLPortContent)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                    trigger OnValidate()
                    begin
                        ExportXMLPort_SaveText(XMLPortContent);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DataportContent := ExportDataPort_ReadText();
        XMLPortContent := ExportXMLPort_ReadText();
    end;

    procedure ExportDataPort_ReadText() BlobText: Text
    var
        BigTextContent: BigText;
        IStr: InStream;
    begin
        rec.CALCFIELDS(ExportDataPort);
        IF NOT Rec."ExportDataPort".HasValue THEN
            EXIT('');
        Rec."ExportDataPort".CreateInStream(IStr);
        BigTextContent.Read(IStr);
        BigTextContent.GetSubText(BlobText, 1);
    end;

    procedure ExportXMLPort_ReadText() BlobText: Text
    var
        BigTextContent: BigText;
        IStr: InStream;
    begin
        rec.CALCFIELDS(ExportXMLPort);
        IF NOT Rec."ExportXMLPort".HasValue THEN
            EXIT('');
        Rec."ExportXMLPort".CreateInStream(IStr);
        BigTextContent.Read(IStr);
        BigTextContent.GetSubText(BlobText, 1);
    end;

    procedure ExportDataPort_SaveText(BlobText: Text)
    var
        OStr: OutStream;
    begin
        CLEAR(Rec."ExportDataPort");
        IF BlobText = '' THEN BEGIN
            rec.Modify();
            exit;
        end;
        Rec."ExportDataPort".CreateOutStream(OStr);
        OStr.WRITETEXT(BlobText);
        rec.Modify()
    end;

    procedure ExportXMLPort_SaveText(BlobText: Text)
    var
        OStr: OutStream;
    begin
        CLEAR(Rec.ExportXMLPort);
        IF BlobText = '' THEN BEGIN
            rec.Modify();
            exit;
        end;
        Rec.ExportXMLPort.CreateOutStream(OStr);
        OStr.WRITETEXT(BlobText);
        rec.Modify()
    end;

    trigger OnOpenPage()
    begin
        rec.InsertWhenEmpty();
    end;

    var
        DataportContent: Text;
        XMLPortContent: Text;
}
