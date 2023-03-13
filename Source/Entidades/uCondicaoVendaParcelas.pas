unit uCondicaoVendaParcelas;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TCondicaoVendaParcelas = class(TInterfacedObject, iEntidade)
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

{ TCondicaoPagamentoParcelas }

constructor TCondicaoVendaParcelas.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CONDICAO_VENDA_PARCELAS where COD_CONDICAO_VENDA = :pCondVenda');

  InicializaDataSource;
end;

destructor TCondicaoVendaParcelas.Destroy;
begin

  inherited;
end;

class function TCondicaoVendaParcelas.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TCondicaoVendaParcelas.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TCondicaoVendaParcelas.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NUM_PARCELA');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TCondicaoVendaParcelas.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From CONDICAO_VENDA_PARCELAS Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TCondicaoVendaParcelas.ModificaDisplayCampos;
begin

end;

function TCondicaoVendaParcelas.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
