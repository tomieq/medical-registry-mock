
        <table class="table table-sm table-striped">
          <thead>
            <tr>
              <th scope="col">GRUPY PYTAŃ</th>
              <th scope="col">CZY GRUPĘ MOŻNA KOPIOWAĆ</th>
              <th scope="col">ACTIONS</th>
            </tr>
          </thead>
          <tbody>
            [START group]
            <tr>
              <td><i data-feather="folder" class="text-light-gray mx-2" style="height: 16px;"></i> <a href="/editProject?projectID={projectID}" class="text-gray">{name}</a></td>
              <td><input type="checkbox" /></td>
              <td>
                <div class="dropdown">
                  <button class="btn text-light-gray" type="button" id="dropdownMenuButton{groupID}" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <i data-feather="more-vertical" class="mx-2" style="height: 16px;"></i>
                  </button>
                  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton{groupID}">
                    <a class="dropdown-item font-14 text-light-gray" href="{renameURL}">Zmień nazwę</a>
                    <a class="dropdown-item font-14 text-light-gray" href="{deleteURL}">Usuń</a>
                  </div>
                </div>
              </td>
            </tr>
            [END group]
          </tbody>
        </table>
