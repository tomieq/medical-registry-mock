
<div class="row">
    <div class="col-12">
        <a href="/addQuestion?projectID={projectID}" class="btn btn-primary"><i class="fa fa-plus"></i> Dodaj pytanie</a>
        <a href="/addDictionary?projectID={projectID}" class="btn btn-secondary"><i class="fa fa-plus"></i> Dodaj słownik</a>
        <a href="/assignUsers?projectID={projectID}" class="btn btn-info"><i class="fa fa-user-friends"></i> Przypisz lekarzy</a>
        <div class="float-right">
            <a href="" class="btn btn-warning"><i class="fa fa-file-excel"></i> Eksportuj do excel</a>
        </div>
    </div>
</div>
<hr>
<div class="row">
    <div class="col-12">
        <h4 class="text-info">Pytania do uzupełniania w projekcie</h4>
    </div>
</div>

<div class="row">
[START question]

    <div class="col-12 col-md-6">
        <div class="card mt-2">
          <div class="card-body">
            <h5 class="card-title">{question}</h5>
            <h6 class="card-subtitle mb-2 text-muted">{type}<span class="text-black-50">{extra}</span></h6>
            
            <a href="/deleteQuestion?questionID={questionID}&projectID={projectID}" class="card-link text-danger">Usuń</a>
            <a href="/editQuestion?questionID={questionID}&projectID={projectID}" class="card-link">Edytuj</a>
          </div>
        </div>
    </div>

[END question]
</div>
<div class="row">
    <div class="col-12">
        <hr>
        <h4 class="text-info">Predefiniowane słowniki do pytań</h4>
    </div>
</div>
<div class="row">
[START dictionary]

    <div class="col-12 col-md-6">
        <div class="card mt-2">
          <div class="card-body">
            <h5 class="card-title">{dictionary}</h5>
            <h6 class="card-subtitle mb-2 text-muted">{type}<span class="text-black-50">{options}</span></h6>
            
            <a href="/deleteDictionary?dictionaryID={dictionaryID}&projectID={projectID}" class="card-link text-danger">Usuń</a>
            <a href="" class="card-link">Edytuj</a>
            
          </div>
        </div>
    </div>

[END dictionary]
</div>
