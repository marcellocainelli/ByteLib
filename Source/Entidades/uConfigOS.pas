unit uConfigOS;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils, Byte.Lib;
Type
  TConfigOS = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;
implementation
uses
  uEntidadeBase;

{ TConfigOS }

constructor TConfigOS.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CONFIG_ORDEMSERVICO where ID = 1');
  InicializaDataSource;
end;

destructor TConfigOS.Destroy;
begin
  inherited;
end;

class function TConfigOS.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConfigOS.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConfigOS.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
end;

function TConfigOS.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConfigOS.ModificaDisplayCampos;
begin
end;

function TConfigOS.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
