<div class="mt-2 mb-2">
    <a href="/editProject?projectID={projectID}&action=dictionaryList&form=new" class="btn btn-purple float-right">+ Dodaj słownik</a>
</div>
<div style="clear: both;"></div>
<div class="row mt-2">
    <div class="col-12">
        <table class="table table-sm table-striped">
          <thead>
            <tr>
              <th scope="col">NAZWA</th>
              <th scope="col" style="width:50px;">AKCJE</th>
            </tr>
          </thead>
          <tbody>
            [START dictionary]
            <tr>
              <td><a href="#" onclick="{previewClick}" class="text-gray">{name}</a></td>
              <td>
                <div class="dropdown">
                  <button class="btn text-light-gray" type="button" id="dropdownMenuButton{dictionaryID}" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <i data-feather="more-vertical" class="mx-2" style="height: 16px;"></i>
                  </button>
                  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton{dictionaryID}">
                    <a class="dropdown-item font-14 text-light-gray" href="#" onclick="{previewClick}">Podgląd</a>
                  </div>
                </div>
              </td>
            </tr>
            [END dictionary]
          </tbody>
        </table>
    </div>
</div>
