using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net.Mime;
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

            _currentStoryParents.Add(_storyTree.First(x => x.Parent == "nothing"));
        }

        private void PopulateStoryTree()
        {
            string jsonFileName = ConfigurationManager.AppSettings["jsonFileName"];
            string jsonFilePath = System.AppDomain.CurrentDomain.BaseDirectory;

            using (StreamReader file = File.OpenText(jsonFilePath + "\\" + jsonFileName))
            {
                JsonSerializer serializer = new JsonSerializer();
                _storyTree = (List<StoryPoint>)serializer.Deserialize(file, typeof(List<StoryPoint>));
            }
        }

        public string Refresh()
        {
            Initialise();

            string errorResult = CheckDataIntegrity();
            LoadOptions();
            string initialText = GetStringOptions(firstTimeIn: true);

            return errorResult == "" ? initialText : errorResult;
        }

        private void RepopulateStoryTree()
        {
            _storyTree.Clear();
            _currentStoryParents.Clear();
            _currentStoryPoints.Clear();

            PopulateStoryTree();

            _currentStoryParents.Add(_storyTree.First(x => x.Parent == "nothing"));
        }

        private string CheckDataIntegrity()
        {
            string result = "";

            LoadOptions();
            GoForward(1);

            CheckAllOptions(ref result);

            RepopulateStoryTree();
            
            return result;
        }

        private void CheckAllOptions(ref string result)
        {
            int numStoryPoints = _currentStoryPoints.Count;
            if (numStoryPoints > 1)
            {
                for (int pointNumber = 1; pointNumber <= numStoryPoints; pointNumber++)
                {
                    GoForward(pointNumber);
                    CheckAllOptions(ref result);
                    GoBack();
                }
            }
            else
            {
                if (numStoryPoints < 1)
                {
                    result = result +
                             string.Format("This option has no children: '{0}' <br/><br/>",
                                           _currentStoryParents[_currentStoryParents.Count - 1].Id);
                }
                else
                {
                    GoForward(1);
                    if (numStoryPoints > 1)
                    {
                        result = result + string.Format("This option should be a leaf, but has children: '{0}' <br/><br/>", _currentStoryParents[_currentStoryParents.Count - 1].Id);
                    }
                    GoBack();
                }
            }
        }

        public void GoBack()
        {
            if (_currentStoryParents.Count > 1)
            {
                _currentStoryParents.Remove(_currentStoryParents[_currentStoryParents.Count - 1]);

                LoadOptions();
            }
            else
            {
                LoadOptions();
            }
        }

        public string GetPreviousOptions()
        {
            string result = "";

            GoBack();

            if (_currentStoryParents.Count > 1)
            {
                result = GetStringOptions();
            }
            else
            {
                result = "You can't go back any further.<br/><br/>" + GetStringOptions(firstTimeIn: true);
            }

            return result;
        }

        public void GoForward(int optionNumber)
        {
            if (optionNumber <= _currentStoryPoints.Count)
            {
                _currentStoryParents.Add(_currentStoryPoints[optionNumber - 1]);
                
                LoadOptions();
            }
        }

        public string GetNextOptions(int optionNumber)
        {
            string result = "";
            
            if (optionNumber <= _currentStoryPoints.Count)
            {
                GoForward(optionNumber);
                result = GetStringOptions();
            }
            else
            {
                result = "Can't find specified option number.";
            }

            return result;
        }

        private string GetStringOptions(bool firstTimeIn = false)
        {
            string options = "No options left.";

            LoadOptions();

            if (_currentStoryPoints.Count > 0)
            {
                options = _currentStoryPoints.Count == 1 && !firstTimeIn ? "<br/>" : "Your options are...<br/><br/><br/><br/>";
                foreach (var storyPoint in _currentStoryPoints)
                {
                    string either = "Either... ";
                    string or = "Or... ";

                    int currentIndex = _currentStoryPoints.IndexOf(storyPoint);
                    string prefix = firstTimeIn ? "1. " : "";
                    if (_currentStoryPoints.Count > 1)
                    {
                        if (currentIndex == 0)
                        {
                            prefix = string.Format("{0}{1}. ", either, currentIndex + 1);
                        }
                        else
                        {
                            prefix = string.Format("{0}{1}. ", or, currentIndex + 1);
                        }
                    }

                    options = options + string.Format("{0}{1}<br/><br/>",
                                                      prefix,
                                                      storyPoint.Id);
                }
            }

            return options;
        }

        private void LoadOptions()
        {
            _currentStoryPoints = _storyTree.Where(x => x.Parent == _currentStoryParents[_currentStoryParents.Count - 1].Id).ToList();
        }
    }
}