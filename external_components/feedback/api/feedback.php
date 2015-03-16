<?php

$data = array();
$map = array();

class Feedback
{
    public $id;
    public $name;
    public $description;
    public $date;
    public $state;

    public static function init($data = array())
    {
        $instance = new self;
        $instance->bind($data);

        if (empty($instance->id)) {
            $instance->id = uniqid('task');
        }

        if (empty($instance->date)) {
            $instance->date = date('Y-m-d H:i:s');
        }

        if (!isset($instance->state)) {
            $instance->state = 0;
        }

        return $instance;
    }

    public function bind($data)
    {
        foreach ($data as $key => $value) {
            $this->$key = $value;
        }
    }

    public function save()
    {
        if (!isset(Feedbacks::$map[$this->id])) {
            Feedbacks::$map[$this->id] = count(Feedbacks::$feedbacks);
            Feedbacks::$feedbacks[] = $this;
        }

        Feedbacks::write();
    }

    public function complete()
    {
        $this->state = 1;
    }

    public function uncomplete()
    {
        $this->state = 0;
    }

    public function delete()
    {
        $index = Feedbacks::$map[$this->id];

        unset(Feedbacks::$map[$this->id]);
        unset(Feedbacks::$feedbacks[$index]);

        Feedbacks::$feedbacks = array_values(Feedbacks::$feedbacks);

        Feedbacks::write();
    }

    public function export()
    {
        return array(
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'date' => $this->date,
            'state' => $this->state
        );
    }
}

class Feedbacks
{
    public static $file = '../.data/data.json';
    public static $map = array();
    public static $feedbacks = array();

    public static function init()
    {
        $contents = null;

        if (file_exists(self::$file)) {
            $contents = file_get_contents(self::$file);
        } else {
            if (!file_exists('../.data')) {
                mkdir('../.data');
            }

            file_put_contents(self::$file, '');
        }

        $result = array();

        if (!empty($contents)) {
            $result = json_decode($contents);
        }

        foreach ($result as $index => $row) {
            self::$map[$row->id] = $index;

            self::$feedbacks[] = Feedback::init($row);
        }
    }

    public static function write()
    {
        $data = array();

        foreach (self::$feedbacks as $index => $feedback)
        {
            $data[] = $feedback->export();
        }

        $file = fopen(self::$file, 'w');
        fwrite($file, json_encode($data));
        fclose($file);
    }

    public static function get($id)
    {
        if (!isset(self::$map[$id])) {
            return Feedback::init();
        }

        $index = self::$map[$id];

        return self::$feedbacks[$index];
    }
}

$post = $_POST;

$file = '../.data/data.json';

if (!empty($post['identifier'])) {
    $file = '../.data/' . $post['identifier'] . '.json';
}

Feedbacks::$file = $file;

Feedbacks::init();

$mode = $post['mode'];

$response = new stdClass;

switch ($mode) {
    case 'add':
        $name = $post['name'];
        $description = $post['description'];

        $feedback = Feedback::init(array(
            'name' => $name,
            'description' => $description
        ));

        $feedback->save();

        $response = $feedback->export();
    break;

    case 'complete':
    case 'uncomplete':
        $id = $post['id'];
        $feedback = Feedbacks::get($id);

        $feedback->$mode();

        $feedback->save();
    break;

    case 'delete':
        $id = $post['id'];
        $feedback = Feedbacks::get($id);

        $feedback->delete();
    break;

    case 'load':
        $data = array();

        foreach (Feedbacks::$feedbacks as $index => $feedback) {
            $data[] = $feedback->export();
        }

        $response = $data;
    break;
}

echo json_encode($response);