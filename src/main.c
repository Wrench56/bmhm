#include <stdint.h>
#include <stdbool.h>

typedef struct efi_table_header {
  uint64_t signature;
  uint32_t revision;
  uint32_t header_size;
  uint32_t crc32;
  uint32_t reserved;
} efi_table_header;

typedef struct efi_simple_text_output_protocol {
  uint64_t (*unused1)(struct efi_simple_text_output_protocol *, bool);
  uint64_t (*output_string)(struct efi_simple_text_output_protocol *self, uint16_t *string);
  uint64_t (*unused2)(struct efi_simple_text_output_protocol *, uint16_t *);
  uint64_t (*unused3)(struct efi_simple_text_output_protocol *, uint64_t, uint64_t *, uint64_t *);
  uint64_t (*unused4)(struct efi_simple_text_output_protocol *, uint64_t);
  uint64_t (*unused5)(struct efi_simple_text_output_protocol *, uint64_t);
  uint64_t (*clear_screen)(struct efi_simple_text_output_protocol *self);
  uint64_t (*unused6)(struct efi_simple_text_output_protocol *, uint64_t, uint64_t);
  uint64_t (*unused7)(struct efi_simple_text_output_protocol *, bool);

  void *unused8;
} efi_simple_text_output_protocol;

typedef struct efi_system_table {
  efi_table_header header;
  uint16_t *unused1;
  uint32_t unused2;
  void *unused3;
  void *unused4;
  void *unused5;
  efi_simple_text_output_protocol *out;
  void *unused6;
  void *unused7;
  void *unused8;
  void *unused9;
  uint64_t unused10;
  void *unused11;
} efi_system_table;


uint64_t efi_main(void *handle, efi_system_table *system_table) {
   uint16_t msg[] = u"Hello World!";
   uint64_t status;

   status = system_table->out->clear_screen(system_table->out);
   if (status != 0)
     return status;

   status = system_table->out->output_string(system_table->out, msg);
   if (status != 0)
     return status;

   while (1) {}

   return 0;
}
