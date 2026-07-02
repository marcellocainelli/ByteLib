unit uOrcamentoHistorico;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TOrcamentoHistorico = class(TInterfacedObject, iEntidade)
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

constructor TOrcamentoHistorico.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ORC_HISTORICO where NR_PEDIDO = :pNr_Pedido');
  InicializaDataSource;
end;

destructor TOrcamentoHistorico.Destroy;
begin
  inherited;
end;

class function TOrcamentoHistorico.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrcamentoHistorico.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrcamentoHistorico.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrcamentoHistorico.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL('Select * From ORC_HISTORICO Where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOrcamentoHistorico.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('data')).EditMask:= '!99/99/00;1;_';
end;

function TOrcamentoHistorico.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
