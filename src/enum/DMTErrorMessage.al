enum 110007 DMTErrMsg
{
    value(0; NoFilePathSelectedError) { Caption = 'No file has been selected.', comment = 'Es wurde keine Datei ausgewählt.'; }
    value(1; NoBufferTableRecorsInFilter) { Caption = 'No buffer table records match the filter.\ Filter: "%1"', comment = 'Keine Puffertabellen-Zeilen im Filter gefunden.\ Filter: "%1"'; }
    value(2; "Process Stopped") { Caption = 'Process Stopped', comment = 'Vorgang abgebrochen'; }
}