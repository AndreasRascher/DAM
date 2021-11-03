page 91008 NAVObjects
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DAMExportObject";

    layout
    {
        area(Content)
        {
            group(Dataport)
            {
                Caption = 'Dataport';
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
                Caption = 'XMLPort';
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
