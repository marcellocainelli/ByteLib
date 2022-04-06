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
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;

      procedure ModificaDisplayCampos;
  end;

implementation

{ TConfig }

constructor TConfigCaixa.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CONFIG_CAIXA WHERE ID = 1');
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
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TConfigCaixa.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConfigCaixa.ModificaDisplayCampos;
begin

end;

end.
