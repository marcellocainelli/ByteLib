unit uItensPedido;

interface

uses
  System.SysUtils,

  Data.DB,

  Model.Entidade.Interfaces;

Type
  TItensPedido = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;

      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TItensPedido }

constructor TItensPedido.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From PEDIDO Where NR_PEDIDO = :Parametro');
end;

destructor TItensPedido.Destroy;
begin
  inherited;
end;

class function TItensPedido.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TItensPedido.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TItensPedido.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;

  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TItensPedido.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TItensPedido.ModificaDisplayCampos;
begin

end;

end.
