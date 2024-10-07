unit uConfigCaixa;

interface

uses
  uEntidadeBase,
  Data.DB,
  Model.Entidade.Interfaces,
  System.SysUtils;

Type
  TConfigCaixa = class(TInterfacedObject, iEntidade)
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

{ TConfig }

constructor TConfigCaixa.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CONFIG_CAIXA WHERE ID = 1');

  InicializaDataSource;
end;

destructor TConfigCaixa.Destroy;
begin

  inherited;
end;

class function TConfigCaixa.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConfigCaixa.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConfigCaixa.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
end;

function TConfigCaixa.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConfigCaixa.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('IMPRIME_CUPOM_PROMOCAO')).currency:= True;
end;

function TConfigCaixa.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
