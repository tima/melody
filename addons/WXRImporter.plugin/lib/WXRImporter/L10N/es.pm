# WXRImporter plugin for Movable Type
# Author: Byrne Reese, Six Apart (http://www.sixapart.com)
# Released under the Artistic License
#
package WXRImporter::L10N::es;

use strict;
use base 'WXRImporter::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
## plugins/WXRImporter/config.yaml
    'Import WordPress exported RSS into MT.' =>
      'Importar WordPress exported RSS hacia MT.',
    '"WordPress eXtended RSS (WXR)"' =>
      '"WordPress eXtended RSS (WXR)"',    # Translate - New
    '"Download WP attachments via HTTP."' =>
      '"Descargar los adjuntos de WP vía HTTP."',    # Translate - New

## plugins/WXRImporter/lib/WXRImporter/Import.pm

## plugins/WXRImporter/lib/WXRImporter/WXRHandler.pm
    'File is not in WXR format.' => 'El fichero no está en el formato WXR.',
    'Creating new tag (\'[_1]\')...' =>
      'Creando nueva etiqueta (\'[_1]\')...',
    'Saving tag failed: [_1]' => 'Fallo al guardar la etiqueta: [_1]',
    'Duplicate asset (\'[_1]\') found.  Skipping.' =>
      'Se encontró un duplicado del fichero multimedia (\'[_1]\'). Ignorado.',
    'Saving asset (\'[_1]\')...' => 'Guardando elemento (\'[_1]\')...',
    ' and asset will be tagged (\'[_1]\')...' =>
      ' y el elemento será etiquetado (\'[_1]\')...',
    'Duplicate entry (\'[_1]\') found.  Skipping.' =>
      'Se encontró un duplicado de la entrada (\'[_1]\'). Ignorada.',
    'Saving page (\'[_1]\')...' => 'Guardando página (\'[_1]\')...',

## plugins/WXRImporter/tmpl/options.tmpl
    'Before you import WordPress posts to Movable Type, we recommend that you <a href=\'[_1]\'>configure your blog\'s publishing paths</a> first.'
      => 'Antes de importar las entradas de WordPress a Movable Type, le recomendamos que primero <a href=\'[_1]\'>configure las rutas de publicación del blog</a>.',
    'Upload path for this WordPress blog' =>
      'Ruta de transferencia para este blog de WordPress',
    'Replace with'         => 'Reemplazar con',
    'Download attachments' => 'Descargar adjuntos',
    'Requires the use of a cron job to download attachments from WordPress powered blog in the background.'
      => 'Necesita el uso de una tarea del cron para descargar los adjuntos de un blog de WordPress en segundo plano.',
    'Download attachments (images and files) from the imported WordPress powered blog.'
      => 'Descargar adjuntos (imágenes y ficheros) de un blog importado de WordPress.',
);

1;

