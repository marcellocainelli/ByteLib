unit uClienteCarro;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TClienteCarro = class(TInterfacedObject, iEntidade)
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

{ TClienteCarro }

constructor TClienteCarro.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CARRO where COD_CLI = :pCod_Cli');
end;

destructor TClienteCarro.Destroy;
begin
  inherited;
end;

class function TClienteCarro.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TClienteCarro.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TClienteCarro.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('NOME_CARRO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TClienteCarro.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TClienteCarro.ModificaDisplayCampos;
begin

end;

end.
