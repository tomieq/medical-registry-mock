
        <table class="table table-sm table-striped">
          <thead>
            <tr>
              <th scope="col">PARAMETR</th>
              <th scope="col">DATA DODANIA</th>
              <th scope="col">TYP</th>
              <th scope="col">AKCJE</th>
            </tr>
          </thead>
          <tbody>
            [START question]
            <tr>
              <td><i data-feather="file-text" class="text-light-gray mx-2" style="height: 16px;"></i> <a href="" class="text-gray">{name}</a></td>
              <td>{createDate}</td>
              <td><span class="label label-purple">{type}</span></td>
              <td>
                <div class="dropdown">
                  <button class="btn text-light-gray" type="button" id="dropdownMenuButton{questionID}" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <i data-feather="more-vertical" class="mx-2" style="height: 16px;"></i>
                  </button>
                  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton{questionID}">
                    <a class="dropdown-item font-14 text-light-gray" href="{deleteURL}">Usuń</a>
                  </div>
                </div>
              </td>
            </tr>
            [END question]
          </tbody>
        </table>
