enum 81122 DMTFileFilter
{
    Extensible = true;

    value(0; All) { Caption = 'All Files (*.*)|*.*', Comment = 'Alle Dateien (*.*)|*.*'; }
    value(1; Excel) { Caption = 'Excel Files (*.xlsx)|*.xlsx', Comment = 'Excel-Dateien (*.xlsx)|*.xlsx'; }
    value(2; ZIP) { Caption = 'ZIP-Dateien (*.zip)|*.zip', Comment = 'ZIP Files (*.zip)|*.zip'; }
    value(3; RDL) { Caption = 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc', Comment = 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc'; }
    value(4; Txt) { Caption = 'Text Files (*.txt)|*.txt', Comment = 'Textdateien (*.txt)|*.txt'; }
    value(5; Xml) { Caption = 'XML Fxiles (*.xml)|*.xml', Comment = 'XML-Dateien (*.xml)|*.xml'; }
    value(6; CSV) { Caption = 'CSV Files|*.csv', Comment = 'CSV Dateien|*.csv'; }
}