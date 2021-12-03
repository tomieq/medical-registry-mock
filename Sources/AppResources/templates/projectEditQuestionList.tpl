
        <table class="table table-sm table-striped">
          <thead>
            <tr>
              <th scope="col">Parametr</th>
              <th scope="col">Data dodania</th>
              <th scope="col">Typ</th>
              <th scope="col">Kolejność</th>
              <th scope="col">Akcje</th>
            </tr>
          </thead>
          <tbody>
            [START question]
            <tr>
              <td><i data-feather="file-text" class="text-light-gray mx-2" style="height: 16px;"></i>
              <a href="#" class="text-gray">{name}</a></td>
              <td>{createDate}</td>
              <td><span class="label label-purple">{type}</span> {unit}</td>
              <td>
                <span class="hand" onclick="{moveUpClick}"><i data-feather="arrow-up" class="mx-2" style="height: 16px;"></i></span>
                <span class="hand" onclick="{moveDownClick}"><i data-feather="arrow-down" class="mx-2" style="height: 16px;"></i></span>
              </td>
              <td>
                <div class="dropdown">
                  <button class="btn text-light-gray" type="button" id="q{questionID}" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <i data-feather="more-vertical" class="mx-2" style="height: 16px;"></i>
                  </button>
                  <div class="dropdown-menu" aria-labelledby="q{questionID}">
                    <a class="dropdown-item font-14 text-light-gray "href="#" onclick="{onclickDelete}">Usuń</a>
                  </div>
                </div>
              </td>
            </tr>
            [END question]
          </tbody>
        </table>
