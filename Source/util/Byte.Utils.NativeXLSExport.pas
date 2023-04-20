unit Byte.Utils.NativeXLSExport;

// based on internet, generate basic BIFF5 XLS
// http://sc.openoffice.org/excelfileformat.pdf
// CodePage support (see WriteCodePage)
// and Unicode compatibility  - Radek Cervinka, delphi.cz
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Grids, Forms,
  Dialogs, db, dbctrls, comctrls;

const
  { BOF }
  CBOF = $0009;
  BIT_BIFF5 = $0800;
  BOF_BIFF5 = CBOF or BIT_BIFF5;
  { EOF }
  BIFF_EOF = $000A;
  { Document types }
  DOCTYPE_XLS = $0010;
  { Dimensions }
  DIMENSIONS = $0000;

type
  TAtributCell = (acHidden, acLocked, acShaded, acBottomBorder, acTopBorder,
    acRightBorder, acLeftBorder, acLeft, acCenter, acRight, acFill);

  TSetOfAtribut = set of TAtributCell;

  TXLSWriter = class(Tobject)
  private
    fstream: TFileStream;
    procedure WriteWord(w: word);
  protected
    procedure WriteBOF;
    procedure WriteEOF;
    procedure WriteDimension;
    procedure WriteCodePage;
  public
    maxCols, maxRows: word;
    procedure CellWord(vCol, vRow: word; aValue: word; vAtribut: TSetOfAtribut = []);
    procedure CellDouble(vCol, vRow: word; aValue: double; vAtribut: TSetOfAtribut = []);
    procedure CellStr(vCol, vRow: word; aValue: String; vAtribut: TSetOfAtribut = []);
    procedure WriteField(vCol, vRow: word; Field: TField);
    constructor create(vFileName: string);
    destructor Destroy; override;
  end;

  procedure SetCellAtribut(value: TSetOfAtribut; var FAtribut: array of System.Byte);
  procedure DataSetToXLS(ds: TDataSet; fname: String);
  procedure StringGridToXLS(grid: TStringGrid; fname: String);

implementation

procedure DataSetToXLS(ds: TDataSet; fname: String);
var
  c, r: Integer;
  xls: TXLSWriter;
begin
  xls := TXLSWriter.create(fname);
  if ds.FieldCount > xls.maxCols then
    xls.maxCols := ds.FieldCount + 1;
  try
    xls.WriteBOF;
    xls.WriteCodePage;

    xls.WriteDimension;
    for c := 0 to ds.FieldCount - 1 do
      xls.CellStr(0, c, ds.Fields[c].FieldName);
    r := 1;
    ds.first;
    while (not ds.eof) and (r <= xls.maxRows) do
    begin
      for c := 0 to ds.FieldCount - 1 do
        xls.WriteField(r, c, ds.Fields[c]);
      inc(r);
      ds.next;
    end;
    xls.WriteEOF;

    // <2002-11-17> dllee
    // ?? Dimension ?? wirteEOF ??,???? if ??? Seek ?? position
    // if r > xls.maxrows then begin
    // xls.maxrows:=r+1;
    // xls.fstream.Seek(10,soFromBeginning);
    // xls.WriteDimension;
    // end;
    // ????? maxrows ?????,????????? 65535,??,?????
  finally
    xls.free;
  end;
end;

procedure StringGridToXLS(grid: TStringGrid; fname: String);
var
  c, r, rMax: Integer;
  xls: TXLSWriter;
begin
  xls := TXLSWriter.create(fname);
  rMax := grid.RowCount;
  if grid.ColCount > xls.maxCols then
    xls.maxCols := grid.ColCount + 1;
  if rMax > xls.maxRows then // ???????? 65535 Rows
    rMax := xls.maxRows;
  try
    xls.WriteBOF;
    xls.WriteDimension;
    for c := 0 to grid.ColCount - 1 do
      for r := 0 to rMax - 1 do
        xls.CellStr(r, c, grid.Cells[c, r]);
    xls.WriteEOF;
  finally
    xls.free;
  end;
end;

{ TXLSWriter }

constructor TXLSWriter.create(vFileName: string);
begin
  inherited create;
  if FileExists(vFileName) then
  begin
    fstream := TFileStream.create(vFileName, fmOpenWrite);
    fstream.Size := 0;
  end
  else
    fstream := TFileStream.create(vFileName, fmCreate);

  maxCols := 100; // <2002-11-17> dllee Column ???????? 65535, ??????
  maxRows := 65535; // <2002-11-17> dllee ???????????,?????????????????
end;

destructor TXLSWriter.destroy;
begin
  if fstream <> nil then
    fstream.free;
  inherited;
end;

procedure TXLSWriter.WriteBOF;
begin
  WriteWord(BOF_BIFF5);
  WriteWord(6); // count of bytes
  WriteWord(0);
  WriteWord(DOCTYPE_XLS);
  WriteWord(0);
end;

procedure TXLSWriter.WriteDimension;
begin
  WriteWord(DIMENSIONS); // dimension OP Code
  WriteWord(8); // count of bytes
  WriteWord(0); // min cols
  WriteWord(maxRows); // max rows
  WriteWord(0); // min rowss
  WriteWord(maxCols); // max cols
end;

procedure TXLSWriter.CellDouble(vCol, vRow: word; aValue: double; vAtribut: TSetOfAtribut);
var
  FAtribut: array [0 .. 2] of System.Byte;
begin
  WriteWord(3); // opcode for double
  WriteWord(15); // count of byte
  WriteWord(vCol);
  WriteWord(vRow);
  SetCellAtribut(vAtribut, FAtribut);
  fstream.Write(FAtribut, 3);
  fstream.Write(aValue, 8);
end;

procedure TXLSWriter.CellWord(vCol, vRow: word; aValue: word;
  vAtribut: TSetOfAtribut = []);
var
  FAtribut: array [0 .. 2] of System.Byte;
begin
  WriteWord(2); // opcode for word
  WriteWord(9); // count of byte
  WriteWord(vCol);
  WriteWord(vRow);
  SetCellAtribut(vAtribut, FAtribut);
  fstream.Write(FAtribut, 3);
  WriteWord(aValue);
end;

procedure TXLSWriter.CellStr(vCol, vRow: word; aValue: String; vAtribut: TSetOfAtribut);
var
  FAtribut: array [0 .. 2] of System.Byte;
  slen: System.Byte;
begin
  WriteWord(4); // opcode for string
  slen := length(aValue);
  WriteWord(slen + 8); // count of byte
  WriteWord(vCol);
  WriteWord(vRow);

  SetCellAtribut(vAtribut, FAtribut);
  fstream.Write(FAtribut, 3);

  fstream.Write(slen, 1);
{$IFDEF UNICODE}
  fstream.Write(AnsiString(aValue)[1], slen);
{$ELSE}
  fstream.Write(aValue[1], slen);
{$ENDIF}
end;

procedure SetCellAtribut(value: TSetOfAtribut; var FAtribut: array of System.Byte);
var
  i: Integer;
begin
  // reset
  for i := 0 to High(FAtribut) do
    FAtribut[i] := 0;

  { Byte Offset     Bit   Description                     Contents
    0          7     Cell is not hidden              0b
    Cell is hidden                  1b
    6     Cell is not locked              0b
    Cell is locked                  1b
    5-0   Reserved, must be 0             000000b
    1          7-6   Font number (4 possible)
    5-0   Cell format code
    2          7     Cell is not shaded              0b
    Cell is shaded                  1b
    6     Cell has no bottom border       0b
    Cell has a bottom border        1b
    5     Cell has no top border          0b
    Cell has a top border           1b
    4     Cell has no right border        0b
    Cell has a right border         1b
    3     Cell has no left border         0b
    Cell has a left border          1b
    2-0   Cell alignment code
    general                    000b
    left                       001b
    center                     010b
    right                      011b
    fill                       100b
    Multiplan default align.   111b
  }

  // bit sequence 76543210

  if acHidden in value then // byte 0 bit 7:
    FAtribut[0] := FAtribut[0] + 128;

  if acLocked in value then // byte 0 bit 6:
    FAtribut[0] := FAtribut[0] + 64;

  if acShaded in value then // byte 2 bit 7:
    FAtribut[2] := FAtribut[2] + 128;

  if acBottomBorder in value then // byte 2 bit 6
    FAtribut[2] := FAtribut[2] + 64;

  if acTopBorder in value then // byte 2 bit 5
    FAtribut[2] := FAtribut[2] + 32;

  if acRightBorder in value then // byte 2 bit 4
    FAtribut[2] := FAtribut[2] + 16;

  if acLeftBorder in value then // byte 2 bit 3
    FAtribut[2] := FAtribut[2] + 8;

  // <2002-11-17> dllee ?? 3 bit ??? 1 ???
  if acLeft in value then // byte 2 bit 1
    FAtribut[2] := FAtribut[2] + 1
  else if acCenter in value then // byte 2 bit 1
    FAtribut[2] := FAtribut[2] + 2
  else if acRight in value then // byte 2, bit 0 dan bit 1
    FAtribut[2] := FAtribut[2] + 3
  else if acFill in value then // byte 2, bit 0
    FAtribut[2] := FAtribut[2] + 4;
end;

procedure TXLSWriter.WriteWord(w: word);
begin
  fstream.Write(w, 2);
end;

procedure TXLSWriter.WriteEOF;
begin
  WriteWord(BIFF_EOF);
  WriteWord(0);
end;

procedure TXLSWriter.WriteField(vCol, vRow: word; Field: TField);
begin
  case Field.DataType of
    ftString, ftWideString, ftBoolean, ftDate, ftDateTime, ftTime:
      CellStr(vCol, vRow, Field.asstring);
    ftAutoInc, ftSmallint, ftInteger, ftWord:
      CellWord(vCol, vRow, Field.AsInteger);
    ftFloat, ftBCD:
      CellDouble(vCol, vRow, Field.AsFloat);
  else
    CellStr(vCol, vRow, EmptyStr); // <2002-11-17> dllee ??????????
  end;
end;

procedure TXLSWriter.WriteCodePage;
begin
  WriteWord($0042); // OPCODE CODEPAGE
  WriteWord($0002); // size
  WriteWord($04E2); // CP1250
  //- >http://sc.openoffice.org/excelfileformat.pdf , section 5.17
end;

end.
