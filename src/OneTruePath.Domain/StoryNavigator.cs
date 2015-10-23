using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json;

namespace OneTruePath.Domain
{
    public class StoryNavigator : IStoryNavigator
    {
        static List<StoryPoint> _storyTree;
        static List<StoryPoint> _currentStoryParents;
        static List<StoryPoint> _currentStoryPoints;

        public void Initialise()
        {
            _storyTree = new List<StoryPoint>();
            _currentStoryParents = new List<StoryPoint>();
            _currentStoryPoints = new List<StoryPoint>();

            PopulateStoryTree();

            //_currentStoryPoints = _storyTree.Where(x => x.Parent == "null").ToList();
            _currentStoryParents.Add(_storyTree.First(x => x.Parent == "nothing"));
        }

        private void PopulateStoryTree()
        {
            using (StreamReader file = File.OpenText(@"C:\_git\OneTruePath\test-import.json"))
            {
                JsonSerializer serializer = new JsonSerializer();
                _storyTree = (List<StoryPoint>)serializer.Deserialize(file, typeof(List<StoryPoint>));
            }
        }

        public string Refresh()
        {
            Initialise();
            return GetOptions();
        }

        public string GoBack()
        {
            string result = "";

            if (_currentStoryParents.Count > 1)
            {
                _currentStoryParents.Remove(_currentStoryParents[_currentStoryParents.Count - 1]);
                
                result = GetOptions();
            }
            else
            {
                result = "You can't go back any further.<br/><br/>" + GetOptions();
            }

            return result;
        }

        public string GoForward(int optionNumber)
        {
            string result = "";

            if (optionNumber <= _currentStoryPoints.Count)
            {
                _currentStoryParents.Add(_currentStoryPoints[optionNumber - 1]);

                result = GetOptions();
            }
            else
            {
                result = "Can't find specified option number.";
            }

            return result;
        }

        private string GetOptions()
        {
            string options = "No child nodes found.";

            _currentStoryPoints = _storyTree.Where(x => x.Parent == _currentStoryParents[_currentStoryParents.Count - 1].Id).ToList();

            if (_currentStoryPoints.Count > 0)
            {
                options = "Your options are...<br/><br/><br/><br/>";
                foreach (var storyPoint in _currentStoryPoints)
                {
                    options = options + string.Format("{0}. {1}<br/><br/>",
                                                      _currentStoryPoints.IndexOf(storyPoint) + 1,
                                                      storyPoint.Id);
                }
            }

            return options;
        }
    }
}