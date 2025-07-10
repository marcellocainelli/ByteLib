unit uOrdemHistorico;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TOrdemHistorico = class(TInterfacedObject, iEntidade)
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

{ TOrdemHistorico }

constructor TOrdemHistorico.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ORD_HISTORICO where NR_ORDEM = :pNr_Ordem');
  InicializaDataSource;
end;

destructor TOrdemHistorico.Destroy;
begin
  inherited;
end;

class function TOrdemHistorico.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrdemHistorico.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrdemHistorico.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrdemHistorico.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL('Select * From ORD_HISTORICO Where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOrdemHistorico.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('data')).EditMask:= '!99/99/00;1;_';
end;

function TOrdemHistorico.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
