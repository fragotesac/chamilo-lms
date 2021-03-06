<?php
/* For licensing terms, see /license.txt */

namespace Chamilo\CoreBundle\Migrations\Schema\V111;

use Chamilo\CoreBundle\Migrations\AbstractMigrationChamilo;
use Doctrine\DBAL\Schema\Schema;

/**
 * Class Version20160706145000
 * Add tag extra field for skills.
 *
 * @package Chamilo\CoreBundle\Migrations\Schema\V111
 */
class Version20160706145000 extends AbstractMigrationChamilo
{
    /**
     * @throws \Doctrine\DBAL\DBALException
     * @throws \Doctrine\DBAL\Schema\SchemaException
     */
    public function up(Schema $schema)
    {
        $connection = $this->connection;
        $sql = "SELECT id FROM extra_field WHERE variable = 'tags'";
        $result = $connection->executeQuery($sql)->fetchAll();
        if (empty($result)) {
            $this->addSql("INSERT INTO extra_field (extra_field_type, field_type, variable, display_text, visible, changeable, created_at) VALUES (8, 10, 'tags', 'Tags', 1, 1, NOW())");
        }
    }

    /**
     * @throws \Doctrine\DBAL\DBALException
     * @throws \Doctrine\DBAL\Schema\SchemaException
     */
    public function down(Schema $schema)
    {
        $this->addSql("DELETE FROM extra_field WHERE extra_field_type = 8 AND field_type = 10 AND variable = 'tags'");
    }
}
