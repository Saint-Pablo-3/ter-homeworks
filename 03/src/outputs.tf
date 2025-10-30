output "vm_info" {
  description = "Список всех ВМ с именем, ID и FQDN"
  value = flatten([
    # 1. ВМ, созданные через count (например web)
    [
      for vm in yandex_compute_instance.web :
      {
        name = vm.name
        id   = vm.id
        fqdn = vm.fqdn
      }
    ],

    # 2. ВМ, созданные через for_each (например db)
    [
      for name, vm in yandex_compute_instance.db :
      {
        name = name
        id   = vm.id
        fqdn = vm.fqdn
      }
    ],

    # 3. Одиночная ВМ (например storage)
    [
      {
        name = yandex_compute_instance.storage.name
        id   = yandex_compute_instance.storage.id
        fqdn = yandex_compute_instance.storage.fqdn
      }
    ]
  ])
}
