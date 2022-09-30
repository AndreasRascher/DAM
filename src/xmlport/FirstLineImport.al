// xmlport 110002 DMTFirstLineImport
// {
//     Caption = 'DMTFirstLineImport';
//     Direction = Import;
//     FieldSeparator = '<TAB>';
//     FieldDelimiter = '<None>';
//     TextEncoding = UTF16;
//     Format = VariableText;
//     FormatEvaluate = Xml;

//     schema
//     {
//         textelement(Root)
//         {
//             tableelement(Lines; Integer)
//             {
//                 textelement(FieldContent)
//                 {
//                     Unbound = true;
//                     trigger OnAfterAssignVariable()
//                     var
//                         RecRef: RecordRef;
//                     begin
//                         CurrColIndex += 1;
//                         If MaxColCount < CurrColIndex then
//                             MaxColCount := CurrColIndex;
//                         Captions.Add(FieldContent);
//                     end;
//                 }
//                 trigger OnBeforeInsertRecord()
//                 begin
//                     ReceivedLinesCount += 1;
//                     currXMLport.Break();
//                 end;

//                 trigger OnAfterInitRecord()
//                 begin
//                     CurrColIndex := 1000; // First Fields starts with 1001
//                 end;
//             }
//         }
//     }

//     requestpage
//     {
//         layout
//         {
//             area(content)
//             {
//                 // group(GroupName)
//                 // {
//                 //     field(Name; SourceExpression)
//                 //     {

//                 //     }
//                 // }
//             }
//         }

//         actions
//         {
//         }
//     }

//     trigger OnPreXmlPort()
//     var
//     begin
//     end;

//     trigger OnPostXmlPort()
//     var
//         LinesProcessedMsg: Label '%1 Buffer\%2 lines imported';
//     begin
//         IF currXMLport.Filename <> '' then //only for manual excecution
//             MESSAGE(LinesProcessedMsg, currXMLport.Filename, ReceivedLinesCount);
//     end;

//     procedure SetDMTTable(DMTTable: Record DMTTable)
//     begin
//         CurrDMTTable := DMTTable;
//         CurrFileName := CurrDMTTable.DataFileName;
//     end;

//     var
//         CurrDMTTable: Record DMTTable;
//         CurrColIndex: Integer;
//         MaxColCount: Integer;
//         ReceivedLinesCount: Integer;
//         CurrFileName: Text;
//         Captions: List of [Text];
// }