unit uPetVacina;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TPetVacina = class(TInterfacedObject, iEntidade)
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

{ TPetVacina }


constructor TPetVacina.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from PET_VACINA');
end;

destructor TPetVacina.Destroy;
begin
  inherited;
end;

class function TPetVacina.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPetVacina.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPetVacina.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPetVacina.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TPetVacina.ModificaDisplayCampos;
begin

end;

end.
